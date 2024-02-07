import 'package:carol/models/int_model.dart';
import 'package:flutter/material.dart';

class StoreNotice extends IntModel {
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
