import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/widgets/cards_explorer/cards_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class CardsGrid extends ConsumerStatefulWidget {
  const CardsGrid({super.key});

  @override
  ConsumerState<CardsGrid> createState() => _CardsGridState();
}

class _CardsGridState extends ConsumerState<CardsGrid> {
  final ScrollController _controller = ScrollController();

  final _items = dummyStampCards;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          // crossAxisSpacing: 20,
          // mainAxisSpacing: 20,
        ),
        controller: _controller,
        itemCount: _items.length + 1,
        itemBuilder: (ctx, index) {
          return CardsListItemCard(
            stampCard: _items[index],
            parentContext: context,
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
