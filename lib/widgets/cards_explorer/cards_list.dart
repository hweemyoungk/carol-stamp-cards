import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/cards_notifier.dart';
import 'package:carol/widgets/cards_explorer/cards_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final customerCardsListCardsProvider =
    StateNotifierProvider<CardsNotifier, List<StampCard>?>(
        (ref) => CardsNotifier());

class CardsList extends ConsumerStatefulWidget {
  const CardsList({
    super.key,
  });

  @override
  ConsumerState<CardsList> createState() => _CardsListState();
}

class _CardsListState extends ConsumerState<CardsList> {
  late AppLocalizations _localizations;

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    final cards = ref.watch(customerCardsListCardsProvider);

    return cards == null
        ? const CircularProgressIndicator()
        : cards.isEmpty
            ? Center(
                child: Text(
                  _localizations.noDataFound,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
              )
            : Expanded(
                child: NotificationListener<ScrollNotification>(
                  // onNotification: _handleScrollNotification,
                  child: ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (ctx, index) {
                      final stampCard = cards[index];
                      return CardsListItemCard(
                        key: ValueKey(stampCard.id),
                        card: stampCard,
                      );
                    },
                  ),
                ),
              );
  }

  // bool _handleScrollNotification(ScrollNotification notification) {
  //   if (notification is ScrollEndNotification) {
  //     print('[+]Got a ScrollEndNotification!');
  //     print('${_controller.position.extentAfter.toStringAsFixed(1)}');
  //     if (_controller.position.extentAfter == 0) {
  //       loadMore();
  //     }
  //   }
  //   return false;
  // }

  // Skip loadMore: Fetch all cards for phase 1
  // Future<void> loadMore() async {
  //   final stampCardsNotifier = ref.read(stampCardsProvider.notifier);
  //   try {
  //     final value = await loadStampCards();
  //     stampCardsNotifier.appendAll(value);
  //   } on Exception catch (e) {
  //     ScaffoldMessenger.of(Carol.materialKey.currentContext!).showSnackBar(
  //       SnackBar(
  //         content: Text('Error during load: ${e.toString()}. Please retry.'),
  //         duration: const Duration(seconds: 3),
  //       ),
  //     );
  //   }
  // }

  // Future<void> _onPressLoadMore() async {
  //   await loadMore();
  // }
}
