import 'package:carol/data/dummy_data.dart';
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/stamp_card_provider.dart';
import 'package:carol/widgets/cards_explorer/cards_list_item_card.dart';
import 'package:carol/widgets/common/load_more_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardsList extends ConsumerStatefulWidget {
  const CardsList({
    super.key,
  });

  @override
  ConsumerState<CardsList> createState() => _CardsListState();
}

class _CardsListState extends ConsumerState<CardsList> {
  final ScrollController _controller = ScrollController();
  final List<StampCard> _stampCards = [];
  bool _initLoaded = false;

  @override
  void initState() {
    super.initState();
    if (StampCardProviders.providers.isNotEmpty) {
      _initLoaded = true;
      for (final entry in StampCardProviders.providers.entries) {
        final stampCard = ref.read(entry.value);
        _stampCards.add(stampCard);
      }
    } else {
      loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_initLoaded
        ? CircularProgressIndicator()
        : Expanded(
            child: NotificationListener<ScrollNotification>(
              // onNotification: _handleScrollNotification,
              child: ListView.builder(
                controller: _controller,
                itemCount: _stampCards.length + 1,
                itemBuilder: (ctx, index) {
                  return index == _stampCards.length
                      ? LoadMoreButton(onPressLoadMore: _onPressLoadMore)
                      : CardsListItemCard(
                          key: ValueKey(_stampCards[index].id),
                          stampCardProvider: StampCardProviders
                              .providers[_stampCards[index].id]!,
                        );
                },
              ),
            ),
          );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      print('[+]Got a ScrollEndNotification!');
      print('${_controller.position.extentAfter.toStringAsFixed(1)}');
      if (_controller.position.extentAfter == 0) {
        loadMore();
      }
    }
    return false;
  }

  Future<void> loadMore() async {
    try {
      final value = await loadStampCards();
      if (mounted) {
        setState(() {
          _stampCards.addAll(value);
          _initLoaded = true;
        });
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(MyApp.materialKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Error during load: ${e.toString()}. Please retry.'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<List<StampCard>> loadStampCards() async {
    await Future.delayed(const Duration(seconds: 2));
    return genDummyStampCards(numCards: 10);
  }

  Future<void> _onPressLoadMore() async {
    await loadMore();
  }
}
