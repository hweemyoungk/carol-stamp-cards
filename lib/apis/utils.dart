import 'dart:async';
import 'dart:io';

import 'package:carol/apis/athena_apis.dart';
import 'package:carol/apis/exceptions/bad_request.dart';
import 'package:carol/apis/exceptions/server_error.dart';
import 'package:carol/apis/exceptions/unauthenticated.dart';
import 'package:carol/apis/exceptions/unauthorized.dart';
import 'package:carol/params/athena.dart' as auth_params;
import 'package:carol/params/app.dart' as app_params;
import 'package:carol/utils.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:retry/retry.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

Future<http.Response> httpGet(
  Uri url, {
  bool withAuthHeaders = true,
  http.Client? client,
}) async {
  final httpClient = client ?? http.Client();
  try {
    final res = await retryOptions.retry(
      () async {
        return httpClient.get(
          url,
          headers: {
            if (withAuthHeaders) ...await getAuthHeaders(),
          },
        ).timeout(const Duration(seconds: app_params.httpTimeoutSeconds));
      },
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    _handleResponse(res);
    return res;
  } finally {
    if (client == null) {
      httpClient.close();
    }
  }
}

Future<http.Response> httpDelete(
  Uri url, {
  Map<String, String>? headers = const {
    'Content-Type': 'application/json;charset=utf-8',
  },
  Object? body,
  http.Client? client,
}) async {
  final httpClient = client ?? http.Client();
  try {
    final res = await retryOptions.retry(
      () async {
        return httpClient.delete(
          url,
          headers: {
            ...await getAuthHeaders(),
            if (headers != null) ...headers,
          },
          body: body,
        );
      },
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    _handleResponse(res);
    return res;
  } finally {
    if (client == null) {
      httpClient.close();
    }
  }
}

Future<http.Response> httpPut(
  Uri url, {
  Map<String, String>? headers = const {
    'Content-Type': 'application/json;charset=UTF-8',
  },
  Object? body,
  http.Client? client,
}) async {
  final httpClient = client ?? http.Client();
  try {
    final res = await retryOptions.retry(
      () async {
        return httpClient.put(
          url,
          headers: {
            ...await getAuthHeaders(),
            if (headers != null) ...headers,
          },
          body: body,
        );
      },
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    _handleResponse(res);
    return res;
  } finally {
    if (client == null) {
      httpClient.close();
    }
  }
}

Future<http.Response> httpPost(
  Uri url, {
  Map<String, String>? headers = const {
    'Content-Type': 'application/json;charset=UTF-8',
  },
  Object? body,
  bool withAuthHeaders = true,
  http.Client? client,
}) async {
  final httpClient = client ?? http.Client();
  try {
    final res = await retryOptions.retry(
      () async {
        return httpClient.post(
          url,
          headers: {
            if (withAuthHeaders) ...await getAuthHeaders(),
            if (headers != null) ...headers,
          },
          body: body,
        );
      },
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    _handleResponse(res);
    return res;
  } finally {
    if (client == null) {
      httpClient.close();
    }
  }
}

Future<Map<String, String>> getAuthHeaders() async {
  if (_refreshOidc) {
    final newOidc = await tryRefreshOidc(
      currentOidc,
      expMarginSeconds: auth_params.expMarginSeconds,
    );
    if (newOidc == null) {
      throw Exception("Failed to refresh OIDC");
    }

    // Replace
    currentOidc = newOidc;

    // Set timer
    setRefreshOidcToggleTimer(oidc: newOidc);
  }

  final headers = {
    'Authorization': 'Bearer ${currentOidc['access_token']}',
  };
  return headers;
}

void _handleResponse(http.Response res) {
  if (res.statusCode < 400) {
    return;
  }

  if (500 <= res.statusCode) {
    throw ServerError(
      '${res.statusCode} Server Error: ${res.body}',
      uri: res.request?.url,
    );
  }

  if (res.statusCode == 400) {
    throw BadRequest(
      '400 Bad Request: ${res.body}',
      uri: res.request?.url,
    );
  }

  if (res.statusCode == 401) {
    throw Unauthenticated(
      '401 Unauthenticated: ${res.body}',
      uri: res.request?.url,
    );
  }

  if (res.statusCode == 403) {
    throw Unauthorized(
      '403 Unauthorized: ${res.body}',
      uri: res.request?.url,
    );
  }

  throw HttpException('${res.statusCode} ${res.reasonPhrase}: ${res.body}');
}

void setRefreshOidcToggleTimer({required Map<String, dynamic> oidc}) {
  final accessTokenExpiresInSeconds = oidc['expires_in'] as int?;
  final int delaySeconds;
  if (accessTokenExpiresInSeconds == null) {
    // Investigate access token
    final accessTokenExp =
        JWT.decode(oidc['access_token']).payload['exp'] as int;
    delaySeconds = accessTokenExp -
        getCurrentTimestampSeconds() -
        auth_params.expMarginSeconds;
  } else {
    delaySeconds = accessTokenExpiresInSeconds - auth_params.expMarginSeconds;
  }

  _refreshOidc = false;
  Future.delayed(
    Duration(seconds: delaySeconds),
    () {
      _refreshOidc = true;
    },
  );
}

Future<void> launchInBrowserView(Uri url) async {
  if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
    throw Exception('Could not launch $url');
  }
}

Object? customToEncodable(dynamic value) {
  if (value is DateTime) {
    // DateTime to Timestamp milliseconds
    return value.millisecondsSinceEpoch;
  }
  return value;
}

int getCurrentTimestampMilliseconds() =>
    DateTime.timestamp().millisecondsSinceEpoch;

int getCurrentTimestampSeconds() =>
    (getCurrentTimestampMilliseconds() / 1000).ceil();

const alphanumericChars =
    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

String genAlphanumeric(int length) => String.fromCharCodes(Iterable.generate(
    length,
    (_) => alphanumericChars
        .codeUnitAt(random.nextInt(alphanumericChars.length))));

const retryOptions = RetryOptions(maxAttempts: app_params.httpMaxRetry);
const durationOneSecond = Duration(seconds: 1);

bool _refreshOidc = true;
late Map<String, dynamic> currentOidc;
