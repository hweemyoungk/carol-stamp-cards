import 'package:flutter/material.dart';

class IconButtonInProgress extends StatelessWidget {
  const IconButtonInProgress({
    super.key,
    this.size = 48,
  });
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: EdgeInsets.all(size / 3),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
