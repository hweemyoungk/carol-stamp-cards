import 'package:carol/models/stamp_card.dart';
import 'package:flutter/material.dart';

class CardsListItemTile extends StatelessWidget {
  final StampCard stampCard;
  const CardsListItemTile({super.key, required this.stampCard});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: stampCard.icon,
      title: Text(stampCard.displayName),
      trailing: Text(stampCard.stampsRatio),
    );
  }
}
