import 'dart:convert';

import 'package:carol/apis/utils.dart';
import 'package:carol/models/app_notice.dart';
import 'package:carol/params/backend.dart' as backend_params;

Map<String, dynamic> minRequirements = {};

Future<Map<String, dynamic>> getMinRequirements() async {
  final url = Uri.https(
    backend_params.appGateway,
    // backend_params.appServiceHost,
    backend_params.appPublicMinRequirementsPath,
  );
  final res = await httpGet(
    url,
    withAuthHeaders: false,
  );
  Map<String, dynamic> resBody = json.decode(res.body);
  return resBody;
}

Future<Set<int>> listAppNoticesId() async {
  final url = Uri.https(
    backend_params.appGateway,
    // backend_params.appServiceHost,
    backend_params.appPublicAppNoticeListIdPath,
  );
  final res = await httpGet(
    url,
    withAuthHeaders: false,
  );
  List<dynamic> resBody = json.decode(res.body);
  return resBody.cast<int>().toSet();
}

Future<List<AppNotice>> listAppNotices({
  required Set<int>? ids,
}) async {
  if (ids != null && ids.isEmpty) return [];

  final url = Uri.https(
    backend_params.appGateway,
    // backend_params.appServiceHost,
    backend_params.appPublicAppNoticeListPath,
    {
      if (ids != null && ids.isNotEmpty)
        'ids': ids.map((e) => e.toString()).toList(),
    },
  );
  final res = await httpGet(
    url,
    withAuthHeaders: false,
  );
  List<dynamic> resBody = json.decode(res.body);

  final List<AppNotice> appNotices = [];
  for (final map in resBody) {
    final stampCard = AppNotice.fromJson(map);
    appNotices.add(stampCard);
  }
  return appNotices;
}
