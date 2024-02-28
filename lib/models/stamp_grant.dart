import 'package:carol/models/int_model.dart';
import 'package:carol/models/stamp_card.dart';

class StampGrant extends IntModel {
  final String displayName;
  final int numStamps;
  final StampCard? card;
  final int cardId;

  StampGrant({
    required super.id,
    required super.isDeleted,
    required this.displayName,
    required this.numStamps,
    required this.card,
    required this.cardId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isDeleted': isDeleted,
        'displayName': displayName,
        'numStamps': numStamps,
        'card': card?.toJson(),
        'cardId': cardId,
      };
}
