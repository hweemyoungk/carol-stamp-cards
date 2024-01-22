import 'package:carol/models/base_model.dart';
import 'package:flutter/material.dart';

class RedeemRule extends BaseModel {
  final String displayName;
  final String description;
  final int consumes;
  final int blueprintId;
  final String? imageId;

  RedeemRule({
    required super.id,
    required this.displayName,
    required this.description,
    required this.consumes,
    this.imageId,
    required this.blueprintId,
  });

  RedeemRule copyWith({
    int? id,
    String? displayName,
    String? description,
    int? consumes,
    int? blueprintId,
    IconData? icon,
    String? imageId,
  }) {
    return RedeemRule(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      consumes: consumes ?? this.consumes,
      blueprintId: blueprintId ?? this.blueprintId,
      imageId: imageId ?? this.imageId,
    );
  }

  RedeemRule.fromJson(Map<String, dynamic> json)
      : displayName = json['displayName'] as String,
        description = json['description'] as String,
        consumes = json['consumes'] as int,
        blueprintId = json['blueprintId'] as int,
        imageId = json['imageId'] as String?,
        super(id: json['id']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'description': description,
        'consumes': consumes,
        'blueprintId': blueprintId,
        'imageId': imageId,
      };

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

  String? get imageUrl {
    return imageId;
    // Skip in phase 1
    // return Uri.http(
    //   imageStorageHost,
    //   '$imageStoragePath/$imageId'
    // ).toString();
  }
}
