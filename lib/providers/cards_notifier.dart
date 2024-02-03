import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/list_notifier.dart';

class CardsNotifier extends ListNotifier<StampCard> {
  CardsNotifier() : super([]);

  @override
  void sort() {
    if (state == null) {
      return;
    }
    state!.sort(
      (card1, card2) =>
          card2.lastModifiedDate.compareTo(card1.lastModifiedDate),
    );
    state = [...state!];
  }
}
