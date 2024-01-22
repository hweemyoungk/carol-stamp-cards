import 'package:carol/models/base_model.dart';

class Redeem extends BaseModel {
  final int numStampsBefore;
  final int numStampsAfter;
  final int redeemRuleId;
  final int cardId;

  Redeem({
    required super.id,
    required this.numStampsBefore,
    required this.numStampsAfter,
    required this.redeemRuleId,
    required this.cardId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'numStampsBefore': numStampsBefore,
        'numStampsAfter': numStampsAfter,
        'redeemRuleId': redeemRuleId,
        'cardId': cardId,
      };
}
