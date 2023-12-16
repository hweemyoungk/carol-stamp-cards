import 'package:carol/models/store.dart';
import 'package:flutter/material.dart';

class StoreInfo extends StatelessWidget {
  const StoreInfo({
    super.key,
    required this.store,
  });

  final Store store;

  @override
  Widget build(BuildContext context) {
    const Widget googleMap =
        Text('Here comes google map. (Click to open external app)');
    return Column(
      children: [
        Text(store.displayName),
        Row(
          children: [
            const Icon(Icons.home),
            Text(store.address),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.phone),
            Text(store.phone),
          ],
        ),
        googleMap,
      ],
    );
  }
}
