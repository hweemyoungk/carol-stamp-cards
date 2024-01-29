import 'package:carol/models/base_model.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:flutter/material.dart';

class StampCardBlueprint extends BaseModel {
  final String displayName;
  final String description;
  final String stampGrantCondDescription;
  final int numMaxStamps;
  final int numMaxRedeems;
  final int numMaxIssuesPerCustomer;
  final int numMaxIssues;
  final DateTime lastModifiedDate;
  final DateTime expirationDate;
  final int storeId;
  final String? bgImageUrl;
  final bool isPublishing;
  List<RedeemRule>? redeemRules;

  StampCardBlueprint({
    required super.id,
    required super.isDeleted,
    required this.displayName,
    required this.description,
    required this.stampGrantCondDescription,
    required this.numMaxStamps,
    required this.lastModifiedDate,
    required this.expirationDate,
    required this.numMaxRedeems,
    required this.numMaxIssuesPerCustomer,
    required this.numMaxIssues,
    required this.storeId,
    required this.bgImageUrl,
    required this.isPublishing,
    required this.redeemRules,
  });

  StampCardBlueprint.fromJson(Map<String, dynamic> json)
      : displayName = json['displayName'] as String,
        description = json['description'] as String,
        stampGrantCondDescription = json['stampGrantCondDescription'] as String,
        numMaxStamps = json['numMaxStamps'] as int,
        numMaxRedeems = json['numMaxRedeems'] as int,
        numMaxIssuesPerCustomer = json['numMaxIssuesPerCustomer'] as int,
        numMaxIssues = json['numMaxIssues'] as int,
        lastModifiedDate =
            DateTime.fromMillisecondsSinceEpoch(json['lastModifiedDate']),
        expirationDate =
            DateTime.fromMillisecondsSinceEpoch(json['expirationDate']),
        storeId = json['storeId'] as int,
        bgImageUrl = json['bgImageUrl'] as String?,
        isPublishing = json['isPublishing'] as bool,
        redeemRules = json['redeemRules'] == null
            ? null
            : [
                for (final map in json['redeemRules']) RedeemRule.fromJson(map),
              ],
        super(
          id: json['id'] as int,
          isDeleted: json['isDeleted'] as bool,
        );

  bool get wasExpired {
    return DateTime.now().isAfter(expirationDate);
  }

  StampCardBlueprint copyWith({
    int? id,
    bool? isDeleted,
    String? displayName,
    String? description,
    String? stampGrantCondDescription,
    int? numMaxStamps,
    int? numMaxRedeems,
    int? numMaxIssuesPerCustomer,
    int? numMaxIssues,
    DateTime? lastModifiedDate,
    DateTime? expirationDate,
    int? storeId,
    IconData? icon,
    String? bgImageUrl,
    bool? isPublishing,
    List<RedeemRule>? redeemRules,
  }) {
    return StampCardBlueprint(
      id: id ?? this.id,
      isDeleted: isDeleted ?? this.isDeleted,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      stampGrantCondDescription:
          stampGrantCondDescription ?? this.stampGrantCondDescription,
      numMaxStamps: numMaxStamps ?? this.numMaxStamps,
      numMaxRedeems: numMaxRedeems ?? this.numMaxRedeems,
      numMaxIssuesPerCustomer:
          numMaxIssuesPerCustomer ?? this.numMaxIssuesPerCustomer,
      numMaxIssues: numMaxIssues ?? this.numMaxIssues,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
      expirationDate: expirationDate ?? this.expirationDate,
      storeId: storeId ?? this.storeId,
      bgImageUrl: bgImageUrl ?? this.bgImageUrl,
      isPublishing: isPublishing ?? this.isPublishing,
      redeemRules: redeemRules ?? this.redeemRules,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isDeleted': isDeleted,
        'displayName': displayName,
        'description': description,
        'stampGrantCondDescription': stampGrantCondDescription,
        'numMaxStamps': numMaxStamps,
        'numMaxRedeems': numMaxRedeems,
        'numMaxIssues': numMaxIssues,
        'numMaxIssuesPerCustomer': numMaxIssuesPerCustomer,
        'lastModifiedDate': lastModifiedDate,
        'expirationDate': expirationDate,
        'storeId': storeId,
        'bgImageUrl': bgImageUrl,
        'isPublishing': isPublishing,
        'redeemRules': redeemRules == null
            ? null
            : [
                for (final redeemRule in redeemRules!) redeemRule.toJson(),
              ],
      };
}
