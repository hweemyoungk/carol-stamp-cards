import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardInfo extends ConsumerWidget {
  final StateNotifierProvider<EntityStateNotifier<StampCard>, StampCard>
      stampCardProvider;
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
          textAlign: TextAlign.center,
          stampCard.displayName,
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
                    stampCard.lastModifiedDateLabel,
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
                    stampCard.expirationDateLabel,
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
