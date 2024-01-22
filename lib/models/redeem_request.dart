class RedeemRequest {
  final String id;
  final int stampCardId;
  final String customerId;
  final String customerDisplayName;
  final String blueprintDisplayName;
  final int redeemRuleId;
  final int ttlMilliseconds;
  final bool isRedeemed;

  RedeemRequest({
    required this.id,
    required this.customerId,
    required this.customerDisplayName,
    required this.stampCardId,
    required this.redeemRuleId,
    required this.blueprintDisplayName,
    required this.ttlMilliseconds,
    required this.isRedeemed,
  });

  RedeemRequest.fromJson(Map<String, dynamic> json)
      : stampCardId = json['cardId'] as int,
        customerId = json['customerId'] as String,
        customerDisplayName = json['customerDisplayName'] as String,
        redeemRuleId = json['redeemRuleId'] as int,
        blueprintDisplayName = json['blueprintDisplayName'] as String,
        ttlMilliseconds = json['ttlMilliseconds'] as int,
        isRedeemed = json['isRedeemed'] as bool,
        id = json['id'] as String;

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerDisplayName': customerDisplayName,
        'cardId': stampCardId,
        'redeemRuleId': redeemRuleId,
        'blueprintDisplayName': blueprintDisplayName,
        'ttlMilliseconds': ttlMilliseconds,
        'isRedeemed': isRedeemed,
      };
}
