import 'dart:core';

import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/store.dart';
import 'package:carol/models/store_notice.dart';
import 'package:carol/models/user.dart';
import 'package:carol/providers/redeem_rule_provider.dart';
import 'package:carol/providers/stamp_card_blueprint_provider.dart';
import 'package:carol/providers/stamp_card_provider.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';

List<StoreNotice> genDummyNotices({
  int numNotices = 3,
  String? storeId,
}) {
  return List.generate(numNotices, (index) {
    final notice = StoreNotice(
      id: uuid.v4(),
      displayName: 'Notice ${index + 1} from store!',
      description:
          'Amet irure ut incididunt officia eiusmod nisi ullamco dolore. Dolore non incididunt eu nisi id commodo aute elit laborum voluptate incididunt. Incididunt aute nisi do eu dolore duis. Exercitation enim minim eiusmod veniam officia exercitation labore est velit est consequat qui. Do anim officia ut sunt. Ut elit aute dolor duis in excepteur. Consectetur deserunt ut proident quis enim.',
      storeId: storeId ?? uuid.v4(),
      icon: random.nextDouble() < 0.5 ? Icons.breakfast_dining : null,
    );
    return notice;
  });
}

List<StampCardBlueprint> genDummyBlueprints({
  int numBps = 3,
  String? storeId,
}) {
  return List.generate(numBps, (index) {
    final blueprint = StampCardBlueprint(
      id: uuid.v4(),
      displayName: 'Blueprint ${index + 1}',
      description:
          'Enim nisi magna ex duis aute eiusmod proident ex anim deserunt ea in elit. Ad elit do irure reprehenderit ut esse commodo sunt adipisicing sunt elit eu. Officia sit nisi sit dolor aliquip exercitation nisi et excepteur. Proident proident commodo velit dolore anim mollit tempor magna ipsum esse irure eiusmod. Laborum excepteur et veniam pariatur aliqua ea culpa sit tempor. Tempor fugiat aute deserunt in voluptate ad pariatur. Nisi est dolore exercitation ipsum deserunt reprehenderit Lorem. Exercitation et cillum quis id. Duis ipsum ut occaecat officia ea pariatur ex laboris id. Et culpa consequat occaecat veniam Lorem aute. Nulla in dolor quis veniam occaecat. Quis eu enim amet ullamco ipsum pariatur pariatur excepteur ea dolore ipsum mollit fugiat. Minim anim qui consectetur laboris in ea aliqua minim sit consectetur aliquip. Fugiat laborum exercitation minim dolor. Proident amet nulla sit deserunt ad est est est cillum cupidatat tempor reprehenderit. In cupidatat cillum aute culpa ex magna nisi do reprehenderit magna consectetur reprehenderit. Enim nisi magna ex duis aute eiusmod proident ex anim deserunt ea in elit. Ad elit do irure reprehenderit ut esse commodo sunt adipisicing sunt elit eu. Officia sit nisi sit dolor aliquip exercitation nisi et excepteur. Proident proident commodo velit dolore anim mollit tempor magna ipsum esse irure eiusmod. Laborum excepteur et veniam pariatur aliqua ea culpa sit tempor. Tempor fugiat aute deserunt in voluptate ad pariatur. Nisi est dolore exercitation ipsum deserunt reprehenderit Lorem. Exercitation et cillum quis id. Duis ipsum ut occaecat officia ea pariatur ex laboris id. Et culpa consequat occaecat veniam Lorem aute. Nulla in dolor quis veniam occaecat. Quis eu enim amet ullamco ipsum pariatur pariatur excepteur ea dolore ipsum mollit fugiat. Minim anim qui consectetur laboris in ea aliqua minim sit consectetur aliquip. Fugiat laborum exercitation minim dolor. Proident amet nulla sit deserunt ad est est est cillum cupidatat tempor reprehenderit. In cupidatat cillum aute culpa ex magna nisi do reprehenderit magna consectetur reprehenderit.',
      stampGrantCondDescription:
          'Proident cillum reprehenderit cupidatat cupidatat sint enim in.',
      numMaxStamps: random.nextInt(50) + 1,
      lastModifiedDate:
          DateTime.now().add(Duration(days: -(random.nextInt(50) + 1))),
      expirationDate:
          DateTime.now().add(Duration(days: random.nextInt(50) + 1)),
      numMaxRedeems: random.nextInt(4), // 0~3, where 0 is infinite
      numMaxIssues: random.nextInt(3) + 1, // 1~3
      storeId: storeId ?? uuid.v4(),
      icon: random.nextDouble() < 0.5 ? Icons.breakfast_dining : null,
      bgImageUrl: random.nextDouble() < 1.0
          // ? 'https://cdn.pixabay.com/photo/2018/03/31/19/29/schnitzel-3279045_1280.jpg'
          ? 'assets/images/schnitzel-3279045_1280.jpg'
          : null,
      isPublishing: random.nextDouble() < 0.5,
    );
    blueprintProviders.tryAddProvider(entity: blueprint);
    return blueprint;
  });
}

List<Store> genDummyCustomerStores({
  int numStores = 3,
  String? ownerId,
}) {
  final stores = genDummyStores(
    numStores: numStores,
    ownerId: ownerId,
  );
  for (final store in stores) {
    customerStoreProviders.tryAddProvider(entity: store);
  }
  return stores;
}

List<Store> genDummyOwnerStores({
  int numStores = 3,
  String? ownerId,
}) {
  final stores = genDummyStores(
    numStores: numStores,
    ownerId: ownerId,
  );
  for (final store in stores) {
    ownerStoreProviders.tryAddProvider(entity: store);
  }
  return stores;
}

List<Store> genDummyStores({
  int numStores = 3,
  String? ownerId,
}) {
  return List.generate(numStores, (index) {
    final store = Store(
      id: uuid.v4(),
      displayName: 'H\'s Bakery $index',
      description:
          'Commodo irure ad adipisicing anim. Pariatur amet culpa nulla magna deserunt commodo est consequat. Aliqua mollit nostrud mollit reprehenderit enim Lorem veniam adipisicing mollit est. Officia anim aliqua anim ea aliqua laboris.\nUt in nostrud mollit elit exercitation mollit. Minim nulla aliqua commodo mollit. Excepteur cupidatat culpa incididunt esse fugiat magna aliquip consectetur. Enim exercitation cillum pariatur adipisicing. Incididunt ut consectetur commodo elit officia tempor cupidatat irure enim non occaecat reprehenderit. Eiusmod fugiat irure officia nulla aliquip aliqua incididunt nulla laboris in id esse. Est aliquip et culpa deserunt fugiat eiusmod fugiat velit dolor voluptate anim et.',
      zipcode: random.nextInt(100000).toString().padLeft(5, '0'),
      address: 'Bar City, Foo State',
      phone: '0212345678',
      lat: 37.29386,
      lng: 37.29386,
      icon: Icons.bakery_dining,
      bgImageUrl: random.nextDouble() < 1.0
          // ? 'https://cdn.pixabay.com/photo/2018/03/31/19/29/schnitzel-3279045_1280.jpg'
          ? 'assets/images/schnitzel-3279045_1280.jpg'
          : null,
      ownerId: uuid.v4(),
    );
    return store;
  });
}

List<StampCard> genDummyStampCards({
  int numCards = 3,
  String? customerId,
  String? storeId,
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
        customerId: customerId ?? uuid.v4(),
        storeId: storeId ?? uuid.v4(),
        bgImageUrl: random.nextDouble() < 0.5
            // ? 'https://cdn.pixabay.com/photo/2018/03/31/19/29/schnitzel-3279045_1280.jpg'
            ? 'assets/images/schnitzel-3279045_1280.jpg'
            : null,
        icon: random.nextDouble() < 0.1 ? Icons.breakfast_dining : null,
      );
      stampCardProviders.tryAddProvider(entity: stampCard);
      return stampCard;
    },
  );
}

List<RedeemRule> genDummySortedRedeemRules(StampCard stampCard) {
  const numRules = 10;
  return List.generate(numRules, (index) {
    final redeemRule = RedeemRule(
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
    redeemRuleProviders.tryAddProvider(entity: redeemRule);
    return redeemRule;
  });
}

final currentUser = User(
  id: uuid.v4(),
  displayName: 'HMK',
  profileImageUrl: 'assets/images/schnitzel-3279045_1280.jpg',
);
