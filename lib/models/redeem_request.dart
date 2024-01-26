import 'package:carol/apis/utils.dart';
import 'package:flutter/material.dart';

class RedeemRequest {
  final String id;
  final int stampCardId;
  final String customerId;
  final String customerDisplayName;
  final String blueprintDisplayName;
  final int redeemRuleId;
  final int expMilliseconds;
  final bool isRedeemed;

  RedeemRequest({
    required this.id,
    required this.customerId,
    required this.customerDisplayName,
    required this.stampCardId,
    required this.redeemRuleId,
    required this.blueprintDisplayName,
    required this.expMilliseconds,
    required this.isRedeemed,
  });

  RedeemRequest.fromJson(Map<String, dynamic> json)
      : stampCardId = json['cardId'] as int,
        customerId = json['customerId'] as String,
        customerDisplayName = json['customerDisplayName'] as String,
        redeemRuleId = json['redeemRuleId'] as int,
        blueprintDisplayName = json['blueprintDisplayName'] as String,
        expMilliseconds = json['expMilliseconds'] as int,
        isRedeemed = json['isRedeemed'] as bool,
        id = json['id'] as String;

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerDisplayName': customerDisplayName,
        'cardId': stampCardId,
        'redeemRuleId': redeemRuleId,
        'blueprintDisplayName': blueprintDisplayName,
        'expMilliseconds': expMilliseconds,
        'isRedeemed': isRedeemed,
      };

  int get ttlMilliseconds =>
      expMilliseconds - getCurrentTimestampMilliseconds();

  bool get expired => ttlMilliseconds < 0;

  Text get remainingSecondsWidget =>
      Text('${(ttlMilliseconds / 1000).floor().toString()}s');
}
