import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/screens/card_screen.dart';
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
    final stampCard = widget.card;
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
              tag: stampCard.id,
              child: stampCard.bgImageUrl == null
                  ? Image.memory(
                      kTransparentImage,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      // image: NetworkImage(stampCard.imageUrl!),
                      image: AssetImage(stampCard.bgImageUrl!),
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
                    stampCard.displayName,
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
                        stampCard.lastModifiedDateLabel,
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
                        stampCard.stampsRatio,
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
                        stampCard.expirationDateLabel,
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
                  stampCard.isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: _onPressFavoriteIcon,
              ),
            ),
            if (stampCard.isInactive)
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
    _loadRedeemRules();

    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) {
        return const CardScreen();
      },
    ));
  }

  Future<void> _loadRedeemRules() async {
    final stampCard = widget.card;
    final Blueprint blueprint;
    if (stampCard.blueprint?.redeemRules == null) {
      // Get Blueprint with non-null redeemRules
      try {
        blueprint = await customer_apis.getBlueprint(id: stampCard.blueprintId);
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: 'Failed to get blueprint information.',
        );
        return;
      }
      // TODO: customer propagate Blueprint with non-null redeemRules
    } else {
      blueprint = stampCard.blueprint!;
    }
  }

  Future<void> _onPressFavoriteIcon() async {
    // TODO: React first

    final bool updatedFavorite;
    try {
      updatedFavorite = await _toggleFavorite(stampCard: widget.card);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to toggle favorite.',
      );
      // TODO: Restore

      return;
    }
    // TODO: Apply backend response
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
