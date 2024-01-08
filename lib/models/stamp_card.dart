import 'package:carol/models/base_model.dart';
import 'package:flutter/material.dart';

class StampCard extends BaseModel {
  final String displayName;
  final int numCollectedStamps;
  final int numGoalStamps;
  final int numMaxStamps;
  final DateTime lastModifiedDate;
  final DateTime expirationDate;
  final bool isFavorite;
  final int numMaxRedeems;
  final int numRedeemed;
  final String customerId;
  final String storeId;
  final String blueprintId;
  final IconData? icon;
  final String? bgImageUrl;
  final bool wasDiscarded;
  final bool wasUsedOut;
  final bool isInactive;

  StampCard({
    required super.id,
    required this.displayName,
    required this.numCollectedStamps,
    required this.numGoalStamps,
    required this.numMaxStamps,
    required this.lastModifiedDate,
    required this.expirationDate,
    required this.isFavorite,
    required this.numMaxRedeems,
    required this.numRedeemed,
    required this.customerId,
    required this.storeId,
    required this.blueprintId,
    this.icon,
    this.bgImageUrl,
    required this.wasDiscarded,
    required this.wasUsedOut,
    required this.isInactive,
  });

  StampCard.fromJson(Map<String, dynamic> json)
      : displayName = json['displayName'] as String,
        numCollectedStamps = json['numCollectedStamps'] as int,
        numGoalStamps = json['numGoalStamps'] as int,
        numMaxStamps = json['numMaxStamps'] as int,
        lastModifiedDate = json['lastModifiedDate'] as DateTime,
        expirationDate = json['expirationDate'] as DateTime,
        isFavorite = json['isFavorite'] as bool,
        numMaxRedeems = json['numMaxRedeems'] as int,
        numRedeemed = json['numRedeemed'] as int,
        customerId = json['customerId'] as String,
        storeId = json['storeId'] as String,
        blueprintId = json['blueprintId'] as String,
        icon = json['icon'] as IconData?,
        bgImageUrl = json['bgImageUrl'] as String?,
        wasDiscarded = json['wasDiscarded'] as bool,
        wasUsedOut = json['wasUsedOut'] as bool,
        isInactive = json['isInactive'] as bool,
        super(id: json['id'] as String);

  StampCard copyWith({
    String? id,
    String? displayName,
    int? numCollectedStamps,
    int? numGoalStamps,
    int? numMaxStamps,
    DateTime? lastModifiedDate,
    DateTime? expirationDate,
    bool? isFavorite,
    int? numMaxRedeems,
    int? numRedeemed,
    String? customerId,
    String? storeId,
    String? blueprintId,
    IconData? icon,
    String? bgImageUrl,
    bool? wasDiscarded,
    bool? wasUsedOut,
    bool? isInactive,
  }) {
    return StampCard(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      numCollectedStamps: numCollectedStamps ?? this.numCollectedStamps,
      numGoalStamps: numGoalStamps ?? this.numGoalStamps,
      numMaxStamps: numMaxStamps ?? this.numMaxStamps,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
      expirationDate: expirationDate ?? this.expirationDate,
      isFavorite: isFavorite ?? this.isFavorite,
      numMaxRedeems: numMaxRedeems ?? this.numMaxRedeems,
      numRedeemed: numRedeemed ?? this.numRedeemed,
      customerId: customerId ?? this.customerId,
      storeId: storeId ?? this.storeId,
      blueprintId: blueprintId ?? this.blueprintId,
      icon: icon ?? this.icon,
      bgImageUrl: bgImageUrl ?? this.bgImageUrl,
      wasDiscarded: wasDiscarded ?? this.wasDiscarded,
      wasUsedOut: wasUsedOut ?? this.wasUsedOut,
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
}

class StampCardQr {
  final String type = 'StampCardQr';
  final StampCard stampCard;

  StampCardQr({required this.stampCard});
}

class SimpleStampCardQr {
  final String type = 'SimpleStampCardQr';
  final String stampCardId;
  final String blueprintId;
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
      : stampCardId = json['stampCardId'] as String,
        blueprintId = json['blueprintId'] as String,
        wasDiscarded = json['wasDiscarded'] as bool,
        wasUsedOut = json['wasUsedOut'] as bool,
        isInactive = json['isInactive'] as bool {
    if (json['type'] != 'SimpleStampCardQr') {
      throw const FormatException('Not valid SimpleStampCardQr');
    }
  }

  SimpleStampCardQr.fromStampCard(StampCard stampCard)
      : stampCardId = stampCard.id,
        blueprintId = stampCard.blueprintId,
        wasDiscarded = stampCard.wasDiscarded,
        wasUsedOut = stampCard.wasUsedOut,
        isInactive = stampCard.isInactive;

  Map<String, dynamic> toJson() => {
        'type': type,
        'stampCardId': stampCardId,
        'blueprintId': blueprintId,
        'wasDiscarded': wasDiscarded,
        'wasUsedOut': wasUsedOut,
        'isInactive': isInactive,
      };
}
