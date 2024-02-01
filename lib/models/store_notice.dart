import 'package:carol/models/base_model.dart';
import 'package:flutter/material.dart';

class StoreNotice extends BaseModel {
  final String displayName;
  final String description;
  final int storeId;
  final IconData? icon;

  StoreNotice({
    required super.id,
    required super.isDeleted,
    required this.displayName,
    required this.description,
    required this.storeId,
    required this.icon,
  });
}

final Map<int, StoreNotice> customerStoreNoticePool = {};
final Map<int, StoreNotice> ownerStoreNoticePool = {};
