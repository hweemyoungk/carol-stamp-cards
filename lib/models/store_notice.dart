import 'package:carol/models/base_model.dart';
import 'package:flutter/material.dart';

class StoreNotice extends BaseModel {
  final String displayName;
  final String description;
  final String storeId;
  final IconData? icon;

  StoreNotice({
    required super.id,
    required this.displayName,
    required this.description,
    required this.storeId,
    required this.icon,
  });
}
