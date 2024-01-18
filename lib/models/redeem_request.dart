import 'package:carol/models/base_model.dart';

class RedeemRequest extends BaseModel {
  final String stampCardId;
  final String redeemRuleId;

  RedeemRequest({
    required super.id,
    required this.stampCardId,
    required this.redeemRuleId,
  });

  /* RedeemRequest.fromJson(Map<String, dynamic> json)
      : stampCardId = json['stampCardId'] as String,
        redeemRuleId = json['redeemRuleId'] as String,
        super(id: json['id'] as String); */

  Map<String, dynamic> toJson() => {
        'id': id,
        'stampCardId': stampCardId,
        'redeemRuleId': redeemRuleId,
      };
}
