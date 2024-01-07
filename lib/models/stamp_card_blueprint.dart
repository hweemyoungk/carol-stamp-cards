import 'package:carol/models/base_model.dart';
import 'package:carol/models/redeem_rule.dart';
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
  final bool isPublishing;
  List<RedeemRule>? redeemRules;

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
    required this.isPublishing,
    required this.redeemRules,
  });

  bool get wasExpired {
    return DateTime.now().isAfter(expirationDate);
  }

  StampCardBlueprint copyWith({
    String? id,
    String? displayName,
    String? description,
    String? stampGrantCondDescription,
    int? numMaxStamps,
    int? numMaxRedeems,
    int? numMaxIssues,
    DateTime? lastModifiedDate,
    DateTime? expirationDate,
    String? storeId,
    IconData? icon,
    String? bgImageUrl,
    bool? isPublishing,
    List<RedeemRule>? redeemRules,
  }) {
    return StampCardBlueprint(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      stampGrantCondDescription:
          stampGrantCondDescription ?? this.stampGrantCondDescription,
      numMaxStamps: numMaxStamps ?? this.numMaxStamps,
      numMaxRedeems: numMaxRedeems ?? this.numMaxRedeems,
      numMaxIssues: numMaxIssues ?? this.numMaxIssues,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
      expirationDate: expirationDate ?? this.expirationDate,
      storeId: storeId ?? this.storeId,
      icon: icon ?? this.icon,
      bgImageUrl: bgImageUrl ?? this.bgImageUrl,
      isPublishing: isPublishing ?? this.isPublishing,
      redeemRules: redeemRules ?? this.redeemRules,
    );
  }
}
