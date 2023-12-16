import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IssuedStampCardsList extends ConsumerStatefulWidget {
  const IssuedStampCardsList({
    super.key,
    required this.store,
  });

  final Store store;

  @override
  ConsumerState<IssuedStampCardsList> createState() =>
      _IssuedStampCardsListState();
}

class _IssuedStampCardsListState extends ConsumerState<IssuedStampCardsList> {
  List<StampCard>? _stampCards;

  @override
  void initState() {
    super.initState();
    loadIssuedStampCards().then((value) {
      setState(() {
        _stampCards = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  Future<List<StampCard>> loadIssuedStampCards() async {
    await Future.delayed(const Duration(seconds: 1));
    throw UnimplementedError();
    // return genDummyStampCards(numCards: 3, notifier: ref.read(provider));
  }
}
