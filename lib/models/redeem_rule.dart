import 'package:carol/models/base_model.dart';
import 'package:flutter/material.dart';

class RedeemRule extends BaseModel {
  final String displayName;
  final String description;
  final int consumes;
  final String blueprintId;
  final String? imageUrl;

  RedeemRule({
    required super.id,
    required this.displayName,
    required this.description,
    required this.consumes,
    required this.blueprintId,
    this.imageUrl,
  });

  RedeemRule copyWith({
    String? id,
    String? displayName,
    String? description,
    int? consumes,
    String? blueprintId,
    IconData? icon,
    String? imageUrl,
  }) {
    return RedeemRule(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      consumes: consumes ?? this.consumes,
      blueprintId: blueprintId ?? this.blueprintId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Widget consumesWidget(TextStyle style, Color color) => SizedBox(
        width: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
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

  RedeemRule.fromJson(Map<String, dynamic> json)
      : displayName = json['displayName'] as String,
        description = json['description'] as String,
        consumes = json['consumes'] as int,
        blueprintId = json['blueprintId'] as String,
        imageUrl = json['imageUrl'] as String?,
        super(id: json['id'] as String);

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'description': description,
        'consumes': consumes,
        'blueprintId': blueprintId,
        'imageUrl': imageUrl,
      };
}
