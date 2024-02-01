import 'package:carol/apis/utils.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:flutter/material.dart';

class RedeemRequest {
  final String id;
  final int stampCardId;
  final String customerId;
  final String customerDisplayName;
  final String blueprintDisplayName;
  final int expMilliseconds;
  final bool isRedeemed;
  final RedeemRule? redeemRule;
  final int redeemRuleId;

  RedeemRequest({
    required this.id,
    required this.customerId,
    required this.customerDisplayName,
    required this.stampCardId,
    required this.blueprintDisplayName,
    required this.expMilliseconds,
    required this.isRedeemed,
    required this.redeemRule,
    required this.redeemRuleId,
  });

  RedeemRequest.fromJson(Map<String, dynamic> json)
      : stampCardId = json['cardId'] as int,
        customerId = json['customerId'] as String,
        customerDisplayName = json['customerDisplayName'] as String,
        blueprintDisplayName = json['blueprintDisplayName'] as String,
        expMilliseconds = json['expMilliseconds'] as int,
        isRedeemed = json['isRedeemed'] as bool,
        id = json['id'] as String,
        redeemRule = json['redeemRule'] == null
            ? null
            : RedeemRule.fromJson(json['redeemRule']),
        redeemRuleId = json['redeemRuleId'] as int;

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerDisplayName': customerDisplayName,
        'cardId': stampCardId,
        'blueprintDisplayName': blueprintDisplayName,
        'expMilliseconds': expMilliseconds,
        'isRedeemed': isRedeemed,
        'redeemRule': redeemRule?.toJson(),
        'redeemRuleId': redeemRuleId,
      };

  int get ttlMilliseconds =>
      expMilliseconds - getCurrentTimestampMilliseconds();

  bool get expired => ttlMilliseconds < 0;

  Text get remainingSecondsWidget =>
      Text('${(ttlMilliseconds / 1000).floor().toString()}s');
}

final Map<String, RedeemRequest> customerRedeemRequestPool = {};
final Map<String, RedeemRequest> ownerRedeemRequestPool = {};
