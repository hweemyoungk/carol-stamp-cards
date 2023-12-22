import 'package:carol/models/base_model.dart';
import 'package:flutter/material.dart';

class StampCardBlueprint extends BaseModel {
  final String displayName;
  final String description;
  final String stampGrantCondDescription;
  final int numMaxStamps;
  final int numMaxRedeems;
  final int numMaxIssues;
  final DateTime lastModifiedDate;
  final DateTime expirationDate;
  final String storeId;
  final IconData? icon;
  final String? bgImageUrl;
  final bool isInactive;

  StampCardBlueprint({
    required super.id,
    required this.displayName,
    required this.description,
    required this.stampGrantCondDescription,
    required this.numMaxStamps,
    required this.lastModifiedDate,
    required this.expirationDate,
    required this.numMaxRedeems,
    required this.numMaxIssues,
    required this.storeId,
    required this.icon,
    required this.bgImageUrl,
    required this.isInactive,
  });
}
