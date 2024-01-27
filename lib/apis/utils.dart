import 'dart:io';

import 'package:carol/apis/auth_apis.dart';
import 'package:carol/params/auth.dart' as auth_params;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

Future<http.Response> httpGet(
  Uri url, {
  bool withAuthHeaders = true,
}) async {
  final res = await httpClient.get(
    url,
    headers: {
      if (withAuthHeaders) ...await getAuthHeaders(),
    },
  );
  if (400 <= res.statusCode) {
    throw HttpException('${res.statusCode} ${res.reasonPhrase}: ${res.body}');
  }
  return res;
}

Future<http.Response> httpDelete(
  Uri url, {
  Map<String, String>? headers = const {
    'Content-Type': 'application/json;charset=utf-8',
  },
  Object? body,
}) async {
  final res = await httpClient.delete(
    url,
    headers: {
      ...await getAuthHeaders(),
      if (headers != null) ...headers,
    },
    body: body,
  );
  if (400 <= res.statusCode) {
    throw HttpException('${res.statusCode} ${res.reasonPhrase}: ${res.body}');
  }
  return res;
}

Future<http.Response> httpPut(
  Uri url, {
  Map<String, String>? headers = const {
    'Content-Type': 'application/json;charset=UTF-8',
  },
  Object? body,
}) async {
  final res = await httpClient.put(
    url,
    headers: {
      ...await getAuthHeaders(),
      if (headers != null) ...headers,
    },
    body: body,
  );
  if (400 <= res.statusCode) {
    throw HttpException('${res.statusCode} ${res.reasonPhrase}: ${res.body}');
  }
  return res;
}

Future<http.Response> httpPost(
  Uri url, {
  Map<String, String>? headers = const {
    'Content-Type': 'application/json;charset=UTF-8',
  },
  Object? body,
  bool withAuthHeaders = true,
}) async {
  final res = await httpClient.post(
    url,
    headers: {
      if (withAuthHeaders) ...await getAuthHeaders(),
      if (headers != null) ...headers,
    },
    body: body,
  );
  if (400 <= res.statusCode) {
    throw HttpException('${res.statusCode} ${res.reasonPhrase}: ${res.body}');
  }
  return res;
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

final httpClient = http.Client();

bool _refreshOidc = true;
late Map<String, dynamic> currentOidc;
