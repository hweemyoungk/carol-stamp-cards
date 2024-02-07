import 'package:carol/models/int_model.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';

class Redeem extends IntModel {
  final int numStampsBefore;
  final int numStampsAfter;
  final String token;
  final RedeemRule? redeemRule;
  final int redeemRuleId;
  final StampCard? card;
  final int cardId;

  Redeem({
    required super.id,
    required super.isDeleted,
    required this.numStampsBefore,
    required this.numStampsAfter,
    required this.token,
    required this.redeemRule,
    required this.redeemRuleId,
    required this.card,
    required this.cardId,
  });

  Redeem.fromJson(Map<String, dynamic> json)
      : numStampsBefore = json['numStampsBefore'] as int,
        numStampsAfter = json['numStampsAfter'] as int,
        token = json['token'] as String,
        redeemRule = json['redeemrule'] == null
            ? null
            : RedeemRule.fromJson(json['redeemrule']),
        redeemRuleId = json['redeemRuleId'] as int,
        card = json['card'] == null ? null : StampCard.fromJson(json['card']),
        cardId = json['cardId'] as int,
        super(
          id: json['id'] as int,
          isDeleted: json['isDeleted'] as bool,
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'isDeleted': isDeleted,
        'numStampsBefore': numStampsBefore,
        'numStampsAfter': numStampsAfter,
        'token': token,
        'redeemRule': redeemRule?.toJson(),
        'redeemRuleId': redeemRuleId,
        'card': card?.toJson(),
        'cardId': cardId,
      };
}
