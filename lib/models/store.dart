import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Store {
  final String id;
  final String displayName;
  final String zipcode;
  final String address;
  final String phone;
  final double lat;
  final double lng;
  final IconData? icon;
  final String? bgImageUrl;
  final String? profileImageUrl;
  final String ownerId;

  Store({
    required this.id,
    required this.displayName,
    required this.zipcode,
    required this.address,
    required this.phone,
    required this.lat,
    required this.lng,
    this.icon,
    this.bgImageUrl,
    this.profileImageUrl,
    required this.ownerId,
  });

  double getDistance(double deviceLat, double deviceLng) {
    final meters = distance(LatLng(lat, lng), LatLng(deviceLat, deviceLng));
    return random.nextDouble() * (random.nextInt(1000) + 1);
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
