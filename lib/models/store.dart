import 'package:carol/models/stamp_card.dart';
import 'package:flutter/material.dart';

class Store {
  final String id;
  final String displayName;
  final String zipcode;
  final String address;
  final String phone;
  final String lat;
  final String lon;
  final List<StampCard> issuedStampCards;
  final List<String> notices;
  final Icon? icon;
  final String? imageUrl;

  Store({
    required this.id,
    required this.displayName,
    required this.zipcode,
    required this.address,
    required this.phone,
    required this.lat,
    required this.lon,
    required this.issuedStampCards,
    required this.notices,
    this.icon,
    this.imageUrl,
  });
}
