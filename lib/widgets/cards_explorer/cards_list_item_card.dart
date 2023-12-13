import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/screens/card_screen.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class CardsListItemCard extends StatefulWidget {
  final StampCard stampCard;
  final BuildContext parentContext;
  const CardsListItemCard({
    super.key,
    required this.stampCard,
    required this.parentContext,
  });

  @override
  State<CardsListItemCard> createState() => _CardsListItemCardState();
}

class _CardsListItemCardState extends State<CardsListItemCard> {
  @override
  void initState() {
    super.initState();
    MyApp.activeContext = context;
  }

  @override
  void dispose() {
    MyApp.activeContext = widget.parentContext;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              tag: widget.stampCard.id,
              child: widget.stampCard.imageUrl == null
                  ? Image.memory(
                      kTransparentImage,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      // image: NetworkImage(widget.stampCard.imageUrl!),
                      image: AssetImage(widget.stampCard.imageUrl!),
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
                    widget.stampCard.displayName,
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
                        widget.stampCard.lastModifiedDateLabel,
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
                        widget.stampCard.stampsRatio,
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
                        widget.stampCard.expirationDateLabel,
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
          ],
        ),
      ),
    );
  }

  void _onTapCardItem() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) {
        return CardScreen(
          stampCard: widget.stampCard,
          parentContext: widget.parentContext,
        );
      },
    ));
  }
}
