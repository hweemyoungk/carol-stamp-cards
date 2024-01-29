import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/main.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/providers/redeem_rule_provider.dart';
import 'package:carol/providers/stamp_card_blueprint_provider.dart';
import 'package:carol/screens/card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class CardsListItemCard extends ConsumerStatefulWidget {
  final StateNotifierProvider<EntityStateNotifier<StampCard>, StampCard>
      stampCardProvider;
  final StateNotifierProvider<EntityStateNotifier<StampCardBlueprint>,
      StampCardBlueprint> blueprintProvider;
  const CardsListItemCard({
    super.key,
    required this.stampCardProvider,
    required this.blueprintProvider,
  });

  @override
  ConsumerState<CardsListItemCard> createState() => _CardsListItemCardState();
}

class _CardsListItemCardState extends ConsumerState<CardsListItemCard> {
  @override
  Widget build(BuildContext context) {
    final stampCard = ref.watch(widget.stampCardProvider);
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
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      // image: NetworkImage(stampCard.imageUrl!),
                      image: AssetImage(stampCard.bgImageUrl!),
                      fit: BoxFit.cover,
                      height: 200,
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
        return CardScreen(
          stampCardProvider: widget.stampCardProvider,
          blueprintProvider: widget.blueprintProvider,
        );
      },
    ));
  }

  Future<void> _loadRedeemRules() async {
    final stampCard = ref.read(widget.stampCardProvider);
    var blueprintProvider =
        blueprintProviders.tryGetProviderById(id: stampCard.blueprintId);
    final StampCardBlueprint blueprint;
    if (blueprintProvider == null) {
      // Get Blueprint
      try {
        blueprint = await customer_apis.getBlueprint(id: stampCard.blueprintId);
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: 'Failed to get blueprint information.',
        );
        return;
      }
      blueprintProviders.tryAddProvider(entity: blueprint);
      blueprintProvider =
          blueprintProviders.tryGetProviderById(id: stampCard.blueprintId)!;
    } else {
      blueprint = ref.read(blueprintProvider);
    }

    if (blueprint.redeemRules == null) {
      if (!mounted) return;

      // List RedeemRules
      final blueprintNotifier = ref.read(blueprintProvider.notifier);
      final List<RedeemRule> redeemRules;
      try {
        redeemRules = await customer_apis.listRedeemRules(
          blueprintId: stampCard.blueprintId,
        );
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: 'Failed to get redeem rules information.',
        );
        return;
      }
      redeemRuleProviders.tryAddProviders(entities: redeemRules);
      blueprintNotifier.set(
        entity: blueprint.copyWith(
          redeemRules: redeemRules,
        ),
      );
    }
  }

  Future<void> _onPressFavoriteIcon() async {
    final originalStampCard = ref.read(widget.stampCardProvider);
    final notifier = ref.read(widget.stampCardProvider.notifier);
    // React first
    notifier.set(
        entity: originalStampCard.copyWith(
            isFavorite: !originalStampCard.isFavorite));
    final bool updatedFavorite;
    try {
      updatedFavorite = await _toggleFavorite(stampCard: originalStampCard);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to toggle favorite.',
      );
      // Restore
      notifier.set(entity: originalStampCard);
      return;
    }
    // Apply backend response
    notifier.set(
        entity: originalStampCard.copyWith(isFavorite: updatedFavorite));
  }

  Future<bool> _toggleFavorite({
    required StampCard stampCard,
  }) async {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () {
    //     // Case: broken integrity by 10%
    //     final integrity = random.nextDouble() < 0.9;
    //     if (!integrity) print('[-]Broken integrity!');
    //     return integrity ? !stampCard.isFavorite : stampCard.isFavorite;
    //   },
    // );
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
