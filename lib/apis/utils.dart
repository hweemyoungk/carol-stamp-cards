import 'dart:io';

import 'package:carol/apis/auth_apis.dart';
import 'package:carol/params/auth.dart' as auth_params;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

Future<http.Response> httpGet(Uri url) async {
  final res = await httpClient.get(
    url,
    headers: getAuthHeaders(),
  );
  if (400 <= res.statusCode) {
    throw HttpException('${res.statusCode} ${res.reasonPhrase}: ${res.body}');
  }
  return res;
}

Future<http.Response> httpDelete(
  Uri url, {
  Map<String, String>? headers = const {
    'Content-Type': 'application/json',
  },
  Object? body,
}) async {
  final res = await httpClient.delete(
    url,
    headers: {
      ...getAuthHeaders(),
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
    'Content-Type': 'application/json',
  },
  Object? body,
}) async {
  final res = await httpClient.put(
    url,
    headers: {
      ...getAuthHeaders(),
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
    'Content-Type': 'application/json',
  },
  Object? body,
  bool withAuthHeaders = true,
}) async {
  final res = await httpClient.post(
    url,
    headers: {
      if (withAuthHeaders) ...getAuthHeaders(),
      if (headers != null) ...headers,
    },
    body: body,
  );
  if (400 <= res.statusCode) {
    throw HttpException('${res.statusCode} ${res.reasonPhrase}: ${res.body}');
  }
  return res;
}

Map<String, String> getAuthHeaders({
  bool tryRefreshToken = true,
}) {
  if (tryRefreshToken) {
    tryRefreshOidc(
      currentOidc,
      expMarginSeconds: auth_params.expMarginSeconds,
    );
  }
  final headers = {
    'Authorization': 'Bearer ${currentOidc['access_token']}',
  };
  return headers;
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

final httpClient = http.Client();

late Map<String, dynamic> currentOidc;
