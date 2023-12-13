import 'package:carol/params.dart';
import 'package:flutter/material.dart';

class RedeemRule {
  final String id;
  final String displayName;
  final String description;
  final int consumes;
  final String stampCardId;
  final IconData? icon;
  final String? imageUrl;

  RedeemRule({
    required this.id,
    required this.displayName,
    required this.description,
    required this.consumes,
    required this.stampCardId,
    this.icon,
    this.imageUrl,
  });

  Widget consumesWidget(TextStyle style, Color color) => SizedBox(
        width: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Params.stampIcon,
              color: color,
              size: style.fontSize,
            ),
            Text(
              '× $consumes',
              style: style.copyWith(color: color),
            ),
          ],
        ),
      );
}
