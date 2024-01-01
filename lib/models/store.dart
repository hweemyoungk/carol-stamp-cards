import 'package:carol/models/base_model.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Store extends BaseModel {
  final String displayName;
  final String description;
  final String zipcode;
  final String address;
  final String phone;
  final double lat;
  final double lng;
  final IconData? icon;
  final String? bgImageUrl;
  final String? profileImageUrl;
  final String ownerId;
  // Assumes Lazy fetch.
  List<StampCardBlueprint>? blueprints;

  Store({
    required super.id,
    required this.displayName,
    required this.description,
    required this.zipcode,
    required this.address,
    required this.phone,
    required this.lat,
    required this.lng,
    this.icon,
    this.bgImageUrl,
    this.profileImageUrl,
    required this.ownerId,
    this.blueprints,
  });

  Store copyWith({
    String? id,
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
    List<StampCardBlueprint>? blueprints,
  }) {
    return Store(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      zipcode: zipcode ?? this.zipcode,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      icon: icon ?? this.icon,
      bgImageUrl: bgImageUrl ?? this.bgImageUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      ownerId: ownerId ?? this.ownerId,
      blueprints: blueprints ?? this.blueprints,
    );
  }

  double getDistance(double deviceLat, double deviceLng) {
    return random.nextDouble() * (random.nextInt(1000) + 1);
    final meters = distance(LatLng(lat, lng), LatLng(deviceLat, deviceLng));
    return meters;
  }

  String getDistanceString(double deviceLat, double deviceLng) {
    final meters = getDistance(deviceLat, deviceLng);
    if (meters < 0) {
      return 'Something\'s really wrong...';
    } else if (meters < 100) {
      return '${meters.ceil()}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }
}
