import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/screens/card_screen.dart';
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class CardsListItemCard extends ConsumerStatefulWidget {
  final StampCard card;
  const CardsListItemCard({
    super.key,
    required this.card,
  });

  @override
  ConsumerState<CardsListItemCard> createState() => _CardsListItemCardState();
}

class _CardsListItemCardState extends ConsumerState<CardsListItemCard> {
  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.hardEdge,
      elevation: 10,
      child: InkWell(
        onTap: _onTapCardItem,
        child: Stack(
          children: [
            Hero(
              tag: card.id,
              child: card.bgImageUrl == null
                  ? Stack(
                      children: [
                        Image.memory(
                          kTransparentImage,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'No Image',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  // ? Image.memory(
                  //     kTransparentImage,
                  //     height: 300,
                  //     width: double.infinity,
                  //     fit: BoxFit.cover,
                  //   )
                  : FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      // image: NetworkImage(stampCard.imageUrl!),
                      image: AssetImage(card.bgImageUrl!),
                      fit: BoxFit.cover,
                      height: 300,
                      width: double.infinity,
                    ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 40,
                ),
                child: Column(children: [
                  Text(
                    card.displayName,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis, // Long tex...
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        card.lastModifiedDateLabel,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        card.stampsRatio,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        card.expirationDateLabel,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(
                  card.isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: _onPressFavoriteIcon,
              ),
            ),
            if (card.isInactive || card.blueprint?.isExpired == true)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onTapCardItem() {
    _notifyCardScreen();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) {
        return const CardScreen();
      },
    ));
  }

  /// Notifies <code>customerCardScreenCardProvider</code>.
  Future<void> _notifyCardScreen() async {
    final cardNotifier = ref.read(customerCardScreenCardProvider.notifier);
    final cardsNotifier = ref.read(customerCardsListCardsProvider.notifier);

    cardNotifier.set(null);

    final card = widget.card;

    if (card.blueprint == null) {
      // Ignore blueprint == null scenario: many-to-one
      Carol.showTextSnackBar(
        text: 'Lost data... Refresh and try again.',
        level: SnackBarLevel.warn,
      );
      return;
    }

    if (card.blueprint!.redeemRules == null) {
      final Blueprint blueprintWithRedeemRules;
      try {
        blueprintWithRedeemRules =
            await card.blueprint!.fetchCustomerRedeemRules();
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: 'Failed to get redeem rules information.',
        );
        return;
      }

      final cardToRefresh = card.copyWith(blueprint: blueprintWithRedeemRules);

      // customerCardsListCardsProvider
      cardsNotifier.replaceIfIdMatch(cardToRefresh);
      // customerStoresListStoresProvider: Not relevant

      cardNotifier.set(cardToRefresh);
      return;
    }

    cardNotifier.set(card);
    return;
  }

  Future<void> _onPressFavoriteIcon() async {
    final originalCard = widget.card.copyWith();
    final cardsNotifier = ref.read(customerCardsListCardsProvider.notifier);
    // React first
    cardsNotifier.replaceIfIdMatch(originalCard.copyWith(
      isFavorite: !originalCard.isFavorite,
    ));

    final bool updatedFavorite;
    try {
      updatedFavorite = await _toggleFavorite(stampCard: widget.card);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to toggle favorite.',
      );
      // Restore
      cardsNotifier.replaceIfIdMatch(originalCard);
      return;
    }

    // Apply backend response
    cardsNotifier.replaceIfIdMatch(originalCard.copyWith(
      isFavorite: updatedFavorite,
    ));
  }

  Future<bool> _toggleFavorite({
    required StampCard stampCard,
  }) async {
    final stampCardToPut = stampCard.copyWith(
      isFavorite: !stampCard.isFavorite,
    );
    await customer_apis.putStampCard(
      id: stampCard.id,
      stampCard: stampCardToPut,
    );
    return stampCardToPut.isFavorite;
  }
}
