import 'package:flutter/material.dart';

class StampCard {
  final String id;
  final String displayName;
  final int numCollectedStamps;
  final int numGoalStamps;
  final int numMaxStamps;
  final DateTime lastModifiedDate;
  final DateTime expirationDate;
  final bool isFavorite;
  final bool isOneTimeUse;
  final Icon? icon;
  final String? imageUrl;

  StampCard({
    required this.id,
    required this.displayName,
    required this.numCollectedStamps,
    required this.numGoalStamps,
    required this.numMaxStamps,
    required this.lastModifiedDate,
    required this.expirationDate,
    required this.isFavorite,
    required this.isOneTimeUse,
    this.icon,
    this.imageUrl,
  });

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
