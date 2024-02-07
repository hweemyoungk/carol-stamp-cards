import 'package:carol/models/int_model.dart';
import 'package:carol/models/redeem.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:flutter/material.dart';

class RedeemRule extends IntModel {
  final String displayName;
  final String description;
  final int consumes;
  final String? imageId;
  final Blueprint? blueprint;
  final int blueprintId;
  final Set<Redeem>? redeems;

  RedeemRule({
    required super.id,
    required super.isDeleted,
    required this.displayName,
    required this.description,
    required this.consumes,
    this.imageId,
    required this.blueprintId,
    required this.blueprint,
    required this.redeems,
  });

  RedeemRule copyWith({
    int? id,
    bool? isDeleted,
    String? displayName,
    String? description,
    int? consumes,
    String? imageId,
    int? blueprintId,
    Blueprint? blueprint,
    Set<Redeem>? redeems,
  }) {
    return RedeemRule(
      id: id ?? this.id,
      isDeleted: isDeleted ?? this.isDeleted,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      consumes: consumes ?? this.consumes,
      imageId: imageId ?? this.imageId,
      blueprintId: blueprintId ?? this.blueprintId,
      blueprint: blueprint ?? this.blueprint,
      redeems: redeems ?? this.redeems,
    );
  }

  RedeemRule.fromJson(Map<String, dynamic> json)
      : displayName = json['displayName'] as String,
        description = json['description'] as String,
        consumes = json['consumes'] as int,
        imageId = json['imageId'] as String?,
        blueprintId = json['blueprintId'] as int,
        blueprint = json['blueprint'] == null
            ? null
            : Blueprint.fromJson(json['blueprint']),
        redeems = json['redeems'] == null
            ? null
            : {
                for (final map in json['redeems']) Redeem.fromJson(map),
              },
        super(
          id: json['id'],
          isDeleted: json['isDeleted'],
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'isDeleted': isDeleted,
        'displayName': displayName,
        'description': description,
        'consumes': consumes,
        'imageId': imageId,
        'blueprintId': blueprintId,
        'blueprint': blueprint?.toJson(),
        'redeems': redeems == null
            ? null
            : [
                for (final redeem in redeems!) redeem.toJson(),
              ],
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
