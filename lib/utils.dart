import 'dart:convert';
import 'dart:math';

import 'package:carol/params/app.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

const int maxInteger = 0x7FFFFFFFFFFFFFFF;
const uuid = Uuid();
final random = Random();
const distance = Distance();
final dateFormatter = DateFormat.yMd();
final timeFormatter = DateFormat.Hms();

const refreshCoolingDuration = Duration(seconds: refreshCoolingSeconds);
const refreshOwnerRedeemRequestsListCoolingDuration =
    Duration(seconds: refreshOwnerRedeemRequestsListCoolingSeconds);

String formatDateTime(DateTime dateTime) {
  return '${timeFormatter.format(dateTime)} ${dateFormatter.format(dateTime)} ${dateTime.timeZoneName} (UTC+${dateTime.timeZoneOffset.inHours})';
}

String formatSeconds(int seconds) {
  final sb = StringBuffer();

  // 1y = 31536000 s
  final year = (seconds / 31536000).floor();
  if (0 < year) {
    sb.write('${year}y ');
  }
  seconds = seconds % 3153600;
  // 1M = 2628000 s
  final month = (seconds / 2628000).floor();
  if (0 < month) {
    sb.write('${month}M ');
  }
  seconds = seconds % 2628000;
  // 1d = 86400 s
  final day = (seconds / 86400).floor();
  if (0 < day) {
    sb.write('${day}d ');
  }
  seconds = seconds % 86400;
  // 1H = 3600 s
  final hour = (seconds / 3600).floor();
  if (0 < hour) {
    sb.write('${hour}h ');
  }
  seconds = seconds % 3600;
  // 1m = 60 s
  final minute = (seconds / 60).floor();
  if (0 < minute) {
    sb.write('${minute}m ');
  }
  seconds = seconds % 60;
  if (0 < seconds) {
    sb.write('${seconds}s ');
  }

  return sb.toString().trim();
}

String formatRemaining(Duration duration) {
  if (duration.isNegative || duration.inSeconds <= 0) {
    return 'Already passed';
  }
  int remaining = duration.inSeconds;
  return '${formatSeconds(remaining)} left';
}

class DesignUtils {
  static const dummyImage =
      AssetImage('assets/images/schnitzel-3279045_1280.jpg');
  static IconData stampIcon = Icons.star;
  static const requiredFieldLabelSuffixText =
      Text('*', style: TextStyle(color: Colors.red));

  static EdgeInsets basicWidgetEdgeInsets([double scale = 1.0]) {
    return EdgeInsets.all(8.0 * scale);
  }

  static List<double> _basicScreenMarginLTRB(
    BuildContext ctx,
    BoxConstraints constraints, [
    double scale = 1.0,
  ]) {
    final left = max(constraints.maxWidth * .1, 8.0) * scale;
    // const left = 0.0;
    // final top = MediaQuery.of(ctx).viewInsets.top +
    //     max(constraints.maxHeight * .05, 8.0) * scale;
    const top = 0.0;
    final right = max(constraints.maxWidth * .1, 8.0) * scale;
    // const right = 0.0;
    final bottom = MediaQuery.of(ctx).viewInsets.bottom +
        max(constraints.maxHeight * .05, 8.0) * scale;
    return [left, top, right, bottom];
  }

  static EdgeInsets basicScreenEdgeInsets(
    BuildContext ctx,
    BoxConstraints constraints, [
    double scale = 1.0,
  ]) {
    final ltrb = _basicScreenMarginLTRB(ctx, constraints, scale);
    return EdgeInsets.fromLTRB(
      ltrb[0],
      ltrb[1],
      ltrb[2],
      ltrb[3],
    );
  }

  // static bool _handleScrollNotification(
  //     ScrollController controller, ScrollNotification notification) {
  //   if (notification is ScrollEndNotification) {
  //     print('[+]Got a ScrollEndNotification!');
  //     print('${controller.position.extentAfter.toStringAsFixed(1)}');
  //     if (controller.position.extentAfter == 0) {
  //       // loadMore();
  //     }
  //   }
  //   return false;
  // }

  static Future<void> delaySeconds(int seconds) async {
    return Future.delayed(Duration(seconds: seconds));
  }
}

// For test
Map<String, dynamic> getStaleRefreshOidc(Map<String, dynamic> oidc) {
  final String refreshToken = oidc['refresh_token'];
  final split = refreshToken.split('.');
  final refreshTokenPayload = json
      .decode(String.fromCharCodes(base64.decode(base64.normalize(split[1]))));
  refreshTokenPayload['exp'] = 1;
  final stalePayload =
      base64.encode(json.encode(refreshTokenPayload).codeUnits);
  final staleToken = [split[0], stalePayload, split[2]].join('.');
  oidc['refresh_token'] = staleToken;
  return oidc;
}
