import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/stamp_card_provider.dart';
import 'package:carol/widgets/cards_explorer/cards_list_item_card.dart';
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

  List<StampCard> _stampCards = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadStampCards().then((value) {
      setState(() {
        _stampCards = value;
      });
      print('CardsList loaded stampcards!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: ListView.builder(
        controller: _controller,
        itemCount: _stampCards.length + 1,
        itemBuilder: (ctx, index) {
          return index == _stampCards.length
              ? const Text(
                  // TODO Implement load symbol.
                  'LOAD MORE?',
                  style: TextStyle(color: Colors.white),
                )
              : CardsListItemCard(
                  provider:
                      StampCardProviders.providers[_stampCards[index].id]!,
                );
        },
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

  void loadMore() async {
    // TODO Implement loadMore
    // throw UnimplementedError();
    await Future.delayed(const Duration(seconds: 2));
    final newDummyStampCards = genDummyStampCards(
      numCards: 10,
    );
    setState(() {
      _stampCards.addAll(newDummyStampCards);
    });
  }

  Future<List<StampCard>> loadStampCards() async {
    await Future.delayed(const Duration(seconds: 1));
    return genDummyStampCards(numCards: 10);
  }
}
