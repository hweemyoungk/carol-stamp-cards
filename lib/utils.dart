import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
final random = Random();
const distance = Distance();

class Utils {
  static EdgeInsets basicWidgetEdgeInsets([double scale = 1.0]) {
    return EdgeInsets.all(8.0 * scale);
  }

  static List<double> _basicScreenMarginLTRB(
    BuildContext ctx,
    BoxConstraints constraints, [
    double scale = 1.0,
  ]) {
    final left = max(constraints.maxWidth * .05, 8.0) * scale;
    final top = MediaQuery.of(ctx).viewPadding.top +
        max(constraints.maxHeight * .05, 8.0) * scale;
    final right = max(constraints.maxWidth * .05, 8.0) * scale;
    final bottom = MediaQuery.of(ctx).viewPadding.bottom +
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

  static bool _handleScrollNotification(
      ScrollController controller, ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      print('[+]Got a ScrollEndNotification!');
      print('${controller.position.extentAfter.toStringAsFixed(1)}');
      if (controller.position.extentAfter == 0) {
        // loadMore();
      }
    }
    return false;
  }
}
