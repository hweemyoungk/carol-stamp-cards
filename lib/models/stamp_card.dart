import 'package:carol/models/base_model.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:flutter/material.dart';

class StampCard extends BaseModel {
  final String displayName;
  final int numCollectedStamps;
  final int numGoalStamps;
  // final int numMaxStamps;
  final DateTime lastModifiedDate;
  final DateTime expirationDate;
  final bool isFavorite;
  // final int numMaxRedeems; // Blueprint can be modified
  final int numRedeemed;
  final String customerId;
  final int storeId;
  final int blueprintId;
  final String? bgImageId;
  final bool isDiscarded;
  final bool isUsedOut;
  final bool isInactive;

  StampCard({
    required super.id,
    required this.displayName,
    required this.numCollectedStamps,
    required this.numGoalStamps,
    // required this.numMaxStamps,
    required this.lastModifiedDate,
    required this.expirationDate,
    required this.isFavorite,
    // required this.numMaxRedeems,
    required this.numRedeemed,
    this.bgImageId,
    required this.isDiscarded,
    required this.isUsedOut,
    required this.isInactive,
    required this.customerId,
    required this.storeId,
    required this.blueprintId,
  });

  StampCard.fromJson(Map<String, dynamic> json)
      : displayName = json['displayName'] as String,
        numCollectedStamps = json['numCollectedStamps'] as int,
        numGoalStamps = json['numGoalStamps'] as int,
        // numMaxStamps = json['numMaxStamps'] as int,
        lastModifiedDate =
            DateTime.fromMillisecondsSinceEpoch(json['lastModifiedDate']),
        expirationDate =
            DateTime.fromMillisecondsSinceEpoch(json['expirationDate']),
        isFavorite = json['isFavorite'] as bool,
        // numMaxRedeems = json['numMaxRedeems'] as int,
        numRedeemed = json['numRedeemed'] as int,
        customerId = json['customerId'] as String,
        storeId = json['storeId'] as int,
        blueprintId = json['blueprintId'] as int,
        bgImageId = json['bgImageId'] as String?,
        isDiscarded = json['isDiscarded'] as bool,
        isUsedOut = json['isUsedOut'] as bool,
        isInactive = json['isInactive'] as bool,
        super(id: json['id'] as int);

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'numCollectedStamps': numCollectedStamps,
        'numGoalStamps': numGoalStamps,
        // 'numMaxStamps': numMaxStamps,
        'lastModifiedDate': lastModifiedDate,
        'expirationDate': expirationDate,
        'isFavorite': isFavorite,
        // 'numMaxRedeems': numMaxRedeems,
        'numRedeemed': numRedeemed,
        'customerId': customerId,
        'storeId': storeId,
        'blueprintId': blueprintId,
        'bgImageId': bgImageId,
        'isDiscarded': isDiscarded,
        'isUsedOut': isUsedOut,
        'isInactive': isInactive,
      };

  StampCard.fromBlueprint({
    required int id,
    required this.customerId,
    required StampCardBlueprint blueprint,
  })  : displayName = blueprint.displayName,
        numCollectedStamps = 0,
        numGoalStamps = blueprint.numMaxStamps,
        // numMaxStamps = blueprint.numMaxStamps,
        lastModifiedDate = DateTime.now(),
        expirationDate = blueprint.expirationDate,
        isFavorite = false,
        // numMaxRedeems = blueprint.numMaxRedeems,
        numRedeemed = 0,
        storeId = blueprint.storeId,
        blueprintId = blueprint.id,
        bgImageId = blueprint.bgImageUrl,
        isDiscarded = false,
        isUsedOut = false,
        isInactive = false,
        super(id: id);

  StampCard copyWith({
    int? id,
    String? displayName,
    int? numCollectedStamps,
    int? numGoalStamps,
    // int? numMaxStamps,
    DateTime? lastModifiedDate,
    DateTime? expirationDate,
    bool? isFavorite,
    // int? numMaxRedeems,
    int? numRedeemed,
    String? customerId,
    int? storeId,
    int? blueprintId,
    IconData? icon,
    String? bgImageId,
    bool? isDiscarded,
    bool? isUsedOut,
    bool? isInactive,
  }) {
    return StampCard(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      numCollectedStamps: numCollectedStamps ?? this.numCollectedStamps,
      numGoalStamps: numGoalStamps ?? this.numGoalStamps,
      // numMaxStamps: numMaxStamps ?? this.numMaxStamps,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
      expirationDate: expirationDate ?? this.expirationDate,
      isFavorite: isFavorite ?? this.isFavorite,
      // numMaxRedeems: numMaxRedeems ?? this.numMaxRedeems,
      numRedeemed: numRedeemed ?? this.numRedeemed,
      customerId: customerId ?? this.customerId,
      storeId: storeId ?? this.storeId,
      blueprintId: blueprintId ?? this.blueprintId,
      bgImageId: bgImageId ?? this.bgImageId,
      isDiscarded: isDiscarded ?? this.isDiscarded,
      isUsedOut: isUsedOut ?? this.isUsedOut,
      isInactive: isInactive ?? this.isInactive,
    );
  }

  String get stampsRatio => '$numCollectedStamps/$numGoalStamps';
  String get lastModifiedDateLabel {
    final diff = DateTime.now().difference(lastModifiedDate);
    if (diff.inDays < 0) {
      return 'Something\'s really wrong...';
    } else if (diff.inDays == 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}d ago';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}M ago';
    } else {
      return '${(diff.inDays % 365).floor()}Y ago';
    }
  }

  String get expirationDateLabel {
    final diff = expirationDate.difference(DateTime.now());
    if (diff.inDays < 0) {
      return 'Expired';
    } else if (diff.inDays == 0) {
      return '${diff.inHours}h left';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}d left';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}M left';
    } else {
      return '${(diff.inDays % 365).floor()}Y left';
    }
  }

  String? get bgImageUrl {
    return bgImageId;
    // Skip in phase 1
    // return Uri.http(
    //   imageStorageHost,
    //   '$imageStoragePath/$imageId'
    // ).toString();
  }
}

class SimpleStampCardQr {
  final String type = 'SimpleStampCardQr';
  final int stampCardId;
  final int blueprintId;
  final bool wasDiscarded;
  final bool wasUsedOut;
  final bool isInactive;

  SimpleStampCardQr({
    required this.stampCardId,
    required this.blueprintId,
    required this.wasDiscarded,
    required this.wasUsedOut,
    required this.isInactive,
  });

  SimpleStampCardQr.fromJson(Map<String, dynamic> json)
      : stampCardId = json['cardId'] as int,
        blueprintId = json['blueprintId'] as int,
        wasDiscarded = json['isDiscarded'] as bool,
        wasUsedOut = json['isUsedOut'] as bool,
        isInactive = json['isInactive'] as bool {
    if (json['type'] != 'SimpleStampCardQr') {
      throw const FormatException('Not valid SimpleStampCardQr');
    }
  }

  SimpleStampCardQr.fromStampCard(StampCard stampCard)
      : stampCardId = stampCard.id,
        blueprintId = stampCard.blueprintId,
        wasDiscarded = stampCard.isDiscarded,
        wasUsedOut = stampCard.isUsedOut,
        isInactive = stampCard.isInactive;

  Map<String, dynamic> toJson() => {
        'type': type,
        'cardId': stampCardId,
        'blueprintId': blueprintId,
        'isDiscarded': wasDiscarded,
        'isUsedOut': wasUsedOut,
        'isInactive': isInactive,
      };
}
