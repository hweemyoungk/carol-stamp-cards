import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/models/base_model.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/widgets/main_drawer.dart';

class StampCard extends BaseModel {
  final String displayName;
  final int numCollectedStamps;
  final int numGoalStamps;
  final DateTime lastModifiedDate;
  final DateTime expirationDate;
  final bool isFavorite;
  final int numRedeemed;
  final String customerId;
  final String? bgImageId;
  final bool isDiscarded;
  final bool isUsedOut;
  final bool isInactive;
  final Blueprint? blueprint;
  final int blueprintId;

  StampCard({
    required super.id,
    required super.isDeleted,
    required this.displayName,
    required this.numCollectedStamps,
    required this.numGoalStamps,
    required this.lastModifiedDate,
    required this.expirationDate,
    required this.isFavorite,
    required this.numRedeemed,
    this.bgImageId,
    required this.isDiscarded,
    required this.isUsedOut,
    required this.isInactive,
    required this.customerId,
    required this.blueprintId,
    required this.blueprint,
  });

  StampCard.fromJson(Map<String, dynamic> json)
      : displayName = json['displayName'] as String,
        numCollectedStamps = json['numCollectedStamps'] as int,
        numGoalStamps = json['numGoalStamps'] as int,
        lastModifiedDate =
            DateTime.fromMillisecondsSinceEpoch(json['lastModifiedDate']),
        expirationDate =
            DateTime.fromMillisecondsSinceEpoch(json['expirationDate']),
        isFavorite = json['isFavorite'] as bool,
        numRedeemed = json['numRedeemed'] as int,
        customerId = json['customerId'] as String,
        bgImageId = json['bgImageId'] as String?,
        isDiscarded = json['isDiscarded'] as bool,
        isUsedOut = json['isUsedOut'] as bool,
        isInactive = json['isInactive'] as bool,
        blueprint = json['blueprint'] == null
            ? null
            : Blueprint.fromJson(json['blueprint']),
        blueprintId = json['blueprintId'] as int,
        super(
          id: json['id'] as int,
          isDeleted: json['isDeleted'] as bool,
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'isDeleted': isDeleted,
        'displayName': displayName,
        'numCollectedStamps': numCollectedStamps,
        'numGoalStamps': numGoalStamps,
        'lastModifiedDate': lastModifiedDate,
        'expirationDate': expirationDate,
        'isFavorite': isFavorite,
        'numRedeemed': numRedeemed,
        'customerId': customerId,
        'bgImageId': bgImageId,
        'isDiscarded': isDiscarded,
        'isUsedOut': isUsedOut,
        'isInactive': isInactive,
        'blueprint': blueprint?.toJson(),
        'blueprintId': blueprintId,
      };

  StampCard.fromBlueprint({
    required int id,
    required this.customerId,
    required Blueprint this.blueprint,
  })  : displayName = blueprint.displayName,
        numCollectedStamps = 0,
        numGoalStamps = blueprint.numMaxStamps,
        lastModifiedDate = DateTime.now(),
        expirationDate = blueprint.expirationDate,
        isFavorite = false,
        numRedeemed = 0,
        bgImageId = blueprint.bgImageUrl,
        isDiscarded = false,
        isUsedOut = false,
        isInactive = false,
        blueprintId = blueprint.id,
        super(
          id: id,
          isDeleted: false,
        );

  StampCard copyWith({
    int? id,
    bool? isDeleted,
    String? displayName,
    int? numCollectedStamps,
    int? numGoalStamps,
    DateTime? lastModifiedDate,
    DateTime? expirationDate,
    bool? isFavorite,
    int? numRedeemed,
    String? customerId,
    String? bgImageId,
    bool? isDiscarded,
    bool? isUsedOut,
    bool? isInactive,
    Blueprint? blueprint,
    int? blueprintId,
  }) {
    return StampCard(
      id: id ?? this.id,
      isDeleted: isDeleted ?? this.isDeleted,
      displayName: displayName ?? this.displayName,
      numCollectedStamps: numCollectedStamps ?? this.numCollectedStamps,
      numGoalStamps: numGoalStamps ?? this.numGoalStamps,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
      expirationDate: expirationDate ?? this.expirationDate,
      isFavorite: isFavorite ?? this.isFavorite,
      numRedeemed: numRedeemed ?? this.numRedeemed,
      customerId: customerId ?? this.customerId,
      bgImageId: bgImageId ?? this.bgImageId,
      isDiscarded: isDiscarded ?? this.isDiscarded,
      isUsedOut: isUsedOut ?? this.isUsedOut,
      isInactive: isInactive ?? this.isInactive,
      blueprintId: blueprintId ?? this.blueprintId,
      blueprint: blueprint ?? this.blueprint,
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
      return '${(diff.inDays % 365).floor()}y ago';
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

  Future<StampCard> fetchBlueprint(
    DrawerItemEnum active, {
    bool force = false,
  }) async {
    if (this.blueprint != null && !force) {
      return this;
    }

    final Blueprint blueprint;
    if (active == DrawerItemEnum.customer) {
      blueprint = await customer_apis.getBlueprint(id: blueprintId);
    } else {
      blueprint = await owner_apis.getBlueprint(id: blueprintId);
    }

    return copyWith(blueprint: blueprint);
  }
}

class SimpleStampCardQr {
  final String type = 'SimpleStampCardQr';
  final int stampCardId;
  final int blueprintId;
  final bool isDiscarded;
  final bool isUsedOut;
  final bool isInactive;

  SimpleStampCardQr({
    required this.stampCardId,
    required this.blueprintId,
    required this.isDiscarded,
    required this.isUsedOut,
    required this.isInactive,
  });

  SimpleStampCardQr.fromJson(Map<String, dynamic> json)
      : stampCardId = json['cardId'] as int,
        blueprintId = json['blueprintId'] as int,
        isDiscarded = json['isDiscarded'] as bool,
        isUsedOut = json['isUsedOut'] as bool,
        isInactive = json['isInactive'] as bool {
    if (json['type'] != 'SimpleStampCardQr') {
      throw const FormatException('Not valid SimpleStampCardQr');
    }
  }

  SimpleStampCardQr.fromStampCard(StampCard stampCard)
      : stampCardId = stampCard.id,
        blueprintId = stampCard.blueprintId,
        isDiscarded = stampCard.isDiscarded,
        isUsedOut = stampCard.isUsedOut,
        isInactive = stampCard.isInactive;

  Map<String, dynamic> toJson() => {
        'type': type,
        'cardId': stampCardId,
        'blueprintId': blueprintId,
        'isDiscarded': isDiscarded,
        'isUsedOut': isUsedOut,
        'isInactive': isInactive,
      };
}
