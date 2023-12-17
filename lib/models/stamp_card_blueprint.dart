import 'package:flutter/material.dart';

class StampCardBlueprint {
  final String id;
  final String displayName;
  final int numMaxStamps;
  final int numMaxRedeems;
  final DateTime lastModifiedDate;
  final DateTime expirationDate;
  final String storeId;
  final IconData? icon;
  final String? bgImageUrl;
  final bool isInactive;

  StampCardBlueprint({
    required this.id,
    required this.displayName,
    required this.numMaxStamps,
    required this.lastModifiedDate,
    required this.expirationDate,
    required this.numMaxRedeems,
    required this.storeId,
    required this.icon,
    required this.bgImageUrl,
    required this.isInactive,
  });
}
