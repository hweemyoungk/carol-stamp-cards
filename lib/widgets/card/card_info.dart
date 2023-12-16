import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/stamp_card_provider.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardInfo extends ConsumerWidget {
  final StateNotifierProvider<StampCardNotifier, StampCard> stampCardProvider;
  const CardInfo({
    super.key,
    required this.stampCardProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stampCard = ref.watch(stampCardProvider);
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
