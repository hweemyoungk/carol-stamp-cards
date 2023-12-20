import 'package:flutter/material.dart';

class StoreNotice {
  final String id;
  final String displayName;
  final String description;
  final String storeId;
  final IconData? icon;

  StoreNotice({
    required this.id,
    required this.displayName,
    required this.description,
    required this.storeId,
    required this.icon,
  });
}
