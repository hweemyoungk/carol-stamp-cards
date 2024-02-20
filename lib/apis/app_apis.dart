import 'dart:convert';

import 'package:carol/apis/utils.dart';
import 'package:carol/params/backend.dart' as backend_params;

Map<String, dynamic> minRequirements = {};

Future<Map<String, dynamic>> getMinRequirements() async {
  final url = Uri.https(
    // backend_params.apigateway,
    backend_params.appServiceHost,
    backend_params.appPublicMinRequirementsPath,
  );
  final res = await httpGet(
    url,
    withAuthHeaders: false,
  );
  Map<String, dynamic> resBody = json.decode(res.body);
  return resBody;
}
