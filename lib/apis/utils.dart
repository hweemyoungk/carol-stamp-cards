import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

Future<http.Response> httpGet(Uri url) async {
  final res = await http.get(
    url,
    headers: getHeaders(),
  );
  if (400 <= res.statusCode) {
    throw HttpException('${res.statusCode} ${res.reasonPhrase}: ${res.body}');
  }
  return res;
}

Future<http.Response> httpPost(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
}) async {
  final res = await http.post(
    url,
    headers: headers,
    body: body,
  );
  if (400 <= res.statusCode) {
    throw HttpException('${res.statusCode} ${res.reasonPhrase}: ${res.body}');
  }
  return res;
}

Map<String, String> getHeaders() {
  final headers = {
    'Authentication': 'Bearer $token',
  };
  return headers;
}

Future<void> launchInBrowserView(Uri url) async {
  if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
    throw Exception('Could not launch $url');
  }
}

late final String token;
