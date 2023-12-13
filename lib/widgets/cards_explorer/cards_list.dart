import 'package:carol/data/dummy_data.dart';
import 'package:carol/main.dart';
import 'package:carol/widgets/cards_explorer/cards_list_item_card.dart';
import 'package:carol/widgets/cards_explorer/cards_list_item_tile.dart';
import 'package:flutter/material.dart';

class CardsList extends StatefulWidget {
  const CardsList({
    super.key,
    required this.parentContext,
  });

  final BuildContext parentContext;

  @override
  State<CardsList> createState() => _CardsListState();
}

class _CardsListState extends State<CardsList> {
  final ScrollController _controller = ScrollController();

  final _items = dummyStampCards;

  @override
  void initState() {
    super.initState();
    MyApp.activeContext = context;
  }

  @override
  void dispose() {
    MyApp.activeContext = widget.parentContext;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: ListView.builder(
        controller: _controller,
        itemCount: _items.length + 1,
        itemBuilder: (ctx, index) {
          return index == _items.length
              ? const Text(
                  // TODO Implement load symbol.
                  'LOAD MORE?',
                  style: TextStyle(color: Colors.white),
                )
              : CardsListItemCard(
                  stampCard: _items[index],
                  parentContext: widget.parentContext,
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

  void loadMore() {
    // TODO Implement loadMore
    throw UnimplementedError();
    setState(() {
      // _items.addAll(List.generate(100, (index) => 'Inserted $index'));
    });
  }
}
