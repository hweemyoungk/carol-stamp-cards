import 'package:carol/models/stamp_card.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';

class CardInfo extends StatelessWidget {
  final StampCard card;
  const CardInfo({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          textAlign: TextAlign.center,
          card.displayName,
          style: Theme.of(context)
              .textTheme
              .displayMedium!
              .copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Last used',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                  Text(
                    card.lastModifiedDateLabel,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Expires in',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                  Text(
                    card.expirationDateLabel,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary),
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
