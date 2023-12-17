import 'dart:core';

import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/store.dart';
import 'package:carol/providers/stamp_card_provider.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';

List<Store> genDummyStores({
  int numStores = 3,
}) {
  return List.generate(numStores, (index) {
    final store = Store(
      id: uuid.v4(),
      displayName: 'H\'s Bakery $index',
      zipcode: random.nextInt(100000).toString().padLeft(5, '0'),
      address: 'Bar City, Foo State',
      phone: '0212345678',
      lat: 37.29386,
      lng: 37.29386,
      icon: Icons.bakery_dining,
      ownerId: uuid.v4(),
    );
    StoreProviders.tryAddProvider(store: store);
    return store;
  });
}

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
      // final wasDiscarded = random.nextDouble() < 0.2;
      // Infinite (50%) / 1~5 (50%)
      final numMaxRedeems =
          random.nextDouble() < 0.5 ? 0 : random.nextInt(5) + 1;
      final numRedeemed = numMaxRedeems == 0
          ? random.nextInt(3)
          : random.nextInt(numMaxRedeems + 1);
      final wasUsedOut =
          numMaxRedeems == 0 ? false : numMaxRedeems == numRedeemed;
      // If not used out, discarded by 20%
      final wasDiscarded = wasUsedOut ? false : random.nextDouble() < 0.2;
      final isInactive = wasUsedOut || wasDiscarded;
      final stampCard = StampCard(
        id: uuid.v4(),
        displayName: 'Card Name $index',
        numCollectedStamps: numCollectedStamps,
        numGoalStamps: numGoalStamps,
        numMaxStamps: numMaxStamps,
        lastModifiedDate: lastModifiedDate,
        expirationDate: expirationDate,
        isFavorite: random.nextDouble() < 0.3,
        numMaxRedeems: numMaxRedeems,
        numRedeemed: numRedeemed,
        wasUsedOut: wasUsedOut,
        wasDiscarded: wasDiscarded,
        isInactive: isInactive,
        customerId: '',
        storeId: '',
        bgImageUrl: random.nextDouble() < 0.5
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
