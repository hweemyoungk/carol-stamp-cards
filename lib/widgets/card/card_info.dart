import 'package:carol/models/stamp_card.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';

class CardInfo extends StatelessWidget {
  final StampCard stampCard;
  const CardInfo({
    super.key,
    required this.stampCard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          stampCard.displayName,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: Utils.basicWidgetEdgeInsets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Last used',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    stampCard.lastModifiedDateLabel,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: Utils.basicWidgetEdgeInsets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Expires in',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    stampCard.expirationDateLabel,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
