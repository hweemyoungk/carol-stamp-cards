import 'package:carol/models/stamp_card.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CardInfo extends StatelessWidget {
  final StampCard card;
  const CardInfo({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final differenceAgo = DateTime.now().difference(card.lastModifiedDate);
    final ago = differenceAgo.isNegative
        ? localizations.hasntComeYet
        : localizations.ago(formatDurationCompact(
            differenceAgo,
            localizations: localizations,
          ));
    final differenceLeft = card.expirationDate.difference(DateTime.now());
    final left = differenceLeft.isNegative
        ? localizations.alreadyPassed
        : localizations.left(formatDurationCompact(
            differenceLeft,
            localizations: localizations,
          ));
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
                    localizations.lastModified,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                  Text(
                    ago,
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
                    localizations.expiredIn,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                  Text(
                    left,
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
