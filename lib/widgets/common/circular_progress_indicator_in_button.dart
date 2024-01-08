import 'package:flutter/material.dart';

class CircularProgressIndicatorInButton extends StatelessWidget {
  const CircularProgressIndicatorInButton({
    super.key,
    required this.color,
  });
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 15,
      height: 15,
      child: CircularProgressIndicator(
        color: color,
      ),
    );
  }
}
