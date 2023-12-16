import 'dart:core';

import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/stamp_card_provider.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<StampCard> genDummyStampCards({
  int numCards = 3,
}) {
  return List.generate(
    numCards,
    (index) {
      final numGoalStamps = random.nextInt(49) + 2;
      final numCollectedStamps = random.nextInt(numGoalStamps + 1);
      final numMaxStamps = numGoalStamps + random.nextInt(5);
      final lastModifiedDate =
          DateTime.now().add(Duration(days: -(random.nextInt(99) + 1)));
      final expirationDate =
          DateTime.now().add(Duration(days: random.nextInt(99) + 1));
      final stampCard = StampCard(
        id: uuid.v4(),
        displayName: 'Card Name $index',
        numCollectedStamps: numCollectedStamps,
        numGoalStamps: numGoalStamps,
        numMaxStamps: numMaxStamps,
        lastModifiedDate: lastModifiedDate,
        expirationDate: expirationDate,
        isFavorite: random.nextDouble() < 0.1,
        isOneTimeUse: random.nextDouble() < 0.5,
        customerId: '',
        ownerId: '',
        imageUrl: random.nextDouble() < 0.5
            // ? 'https://cdn.pixabay.com/photo/2018/03/31/19/29/schnitzel-3279045_1280.jpg'
            ? 'assets/images/schnitzel-3279045_1280.jpg'
            : null,
        icon: random.nextDouble() < 0.1
            ? const Icon(Icons.breakfast_dining)
            : null,
      );
      StampCardProviders.tryAddProvider(stampCard: stampCard);
      return stampCard;
    },
  );
}

List<RedeemRule> genDummySortedRedeemRules(StampCard stampCard) {
  const numRules = 10;
  return List.generate(numRules, (index) {
    return RedeemRule(
      id: uuid.v4(),
      consumes: (stampCard.numMaxStamps / (numRules - index)).ceil(),
      displayName: '${index + 1} Cookies',
      description: 'Presents ${index + 1} cookies.',
      stampCardId: stampCard.id,
      imageUrl: random.nextDouble() < 0.5
          // ? 'https://cdn.pixabay.com/photo/2018/03/31/19/29/schnitzel-3279045_1280.jpg'
          ? 'assets/images/schnitzel-3279045_1280.jpg'
          : null,
      icon: random.nextDouble() < 0.5 ? Icons.cookie : null,
    );
  });
}
