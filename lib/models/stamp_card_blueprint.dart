import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/models/int_model.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/store.dart';
import 'package:flutter/material.dart';

class Blueprint extends IntModel {
  final String displayName;
  final String description;
  final String stampGrantCondDescription;
  final int numMaxStamps;
  final int numMaxRedeems;
  final int numMaxIssuesPerCustomer;
  final int numMaxIssues;
  final DateTime lastModifiedDate;
  final DateTime expirationDate;
  final String? bgImageUrl;
  final bool isPublishing;
  final Store? store;
  final int storeId;
  final Set<RedeemRule>? redeemRules;

  Blueprint({
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
    required this.bgImageUrl,
    required this.isPublishing,
    required this.store,
    required this.storeId,
    required this.redeemRules,
  });

  Blueprint.fromJson(Map<String, dynamic> json)
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
        bgImageUrl = json['bgImageUrl'] as String?,
        isPublishing = json['isPublishing'] as bool,
        store = json['store'] == null ? null : Store.fromJson(json['store']),
        storeId = json['storeId'] ?? -1,
        redeemRules = json['redeemRules'] == null
            ? null
            : {
                for (final map in json['redeemRules']) RedeemRule.fromJson(map),
              },
        super(
          id: json['id'] as int,
          isDeleted: json['isDeleted'] as bool,
        );

  Blueprint copyWith({
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
    IconData? icon,
    String? bgImageUrl,
    bool? isPublishing,
    Store? store,
    int? storeId,
    Set<RedeemRule>? redeemRules,
  }) {
    return Blueprint(
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
      bgImageUrl: bgImageUrl ?? this.bgImageUrl,
      isPublishing: isPublishing ?? this.isPublishing,
      store: store ?? this.store,
      storeId: storeId ?? this.storeId,
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
        'bgImageUrl': bgImageUrl,
        'isPublishing': isPublishing,
        'store': store?.toJson(),
        'storeId': storeId,
        'redeemRules': redeemRules == null
            ? null
            : [
                for (final redeemRule in redeemRules!) redeemRule.toJson(),
              ],
      };

  bool get isExpired {
    return DateTime.now().isAfter(expirationDate);
  }

  Future<Blueprint> fetchCustomerRedeemRules({bool force = false}) async {
    if (this.redeemRules != null && !force) {
      return this;
    }

    final Set<RedeemRule> redeemRules;
    redeemRules = await customer_apis.listRedeemRules(blueprintId: id);
    return copyWith(redeemRules: redeemRules);
  }

  Future<Blueprint> fetchOwnerRedeemRules({bool force = false}) async {
    if (this.redeemRules != null && !force) {
      return this;
    }

    final Set<RedeemRule> redeemRules;
    redeemRules = await owner_apis.listRedeemRules(blueprintId: id);
    return copyWith(redeemRules: redeemRules);
  }
}
