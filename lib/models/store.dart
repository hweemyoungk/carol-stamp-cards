import 'package:carol/models/int_model.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Store extends IntModel {
  final String displayName;
  final String description;
  final String zipcode;
  final String address;
  final String phone;
  final double lat;
  final double lng;
  final String? bgImageUrl;
  final String? profileImageUrl;
  final String ownerId;
  final Set<Blueprint>? blueprints;

  Store({
    required super.id,
    required super.isDeleted,
    required this.displayName,
    required this.description,
    required this.zipcode,
    required this.address,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.bgImageUrl,
    required this.profileImageUrl,
    required this.ownerId,
    required this.blueprints,
  });

  Store.fromJson(Map<String, dynamic> json)
      : displayName = json['displayName'] as String,
        description = json['description'] as String,
        zipcode = json['zipcode'] as String,
        address = json['address'] as String,
        phone = json['phone'] as String,
        lat = json['lat'] as double,
        lng = json['lng'] as double,
        bgImageUrl = json['bgImageUrl'] as String?,
        profileImageUrl = json['profileImageUrl'] as String?,
        ownerId = json['ownerId'] as String,
        blueprints = json['blueprints'] == null
            ? null
            : {
                for (final map in json['blueprints']) Blueprint.fromJson(map),
              },
        super(
          id: json['id'] as int,
          isDeleted: json['isDeleted'] as bool,
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'isDeleted': isDeleted,
        'displayName': displayName,
        'description': description,
        'zipcode': zipcode,
        'address': address,
        'phone': phone,
        'lat': lat,
        'lng': lng,
        'bgImageUrl': bgImageUrl,
        'profileImageUrl': profileImageUrl,
        'ownerId': ownerId,
        'blueprints': blueprints == null
            ? null
            : [
                for (final blueprint in blueprints!) blueprint.toJson(),
              ],
      };

  Store copyWith({
    int? id,
    bool? isDeleted,
    String? displayName,
    String? description,
    String? zipcode,
    String? address,
    String? phone,
    double? lat,
    double? lng,
    IconData? icon,
    String? bgImageUrl,
    String? profileImageUrl,
    String? ownerId,
    Set<Blueprint>? blueprints,
  }) {
    return Store(
      id: id ?? this.id,
      isDeleted: isDeleted ?? this.isDeleted,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      zipcode: zipcode ?? this.zipcode,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      bgImageUrl: bgImageUrl ?? this.bgImageUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      ownerId: ownerId ?? this.ownerId,
      blueprints: blueprints ?? this.blueprints,
    );
  }

  double getDistanceMeters(double deviceLat, double deviceLng) {
    // return random.nextDouble() * (random.nextInt(1000) + 1);
    final meters = distance(LatLng(lat, lng), LatLng(deviceLat, deviceLng));
    return meters;
  }

  String getDistanceString(double deviceLat, double deviceLng) {
    final meters = getDistanceMeters(deviceLat, deviceLng);
    if (meters < 0) {
      return 'Something\'s really wrong...';
    } else if (meters < 100) {
      return '${meters.ceil()}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }
}
