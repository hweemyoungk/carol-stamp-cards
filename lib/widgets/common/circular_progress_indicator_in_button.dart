import 'package:flutter/material.dart';

class CircularProgressIndicatorInButton extends StatelessWidget {
  const CircularProgressIndicatorInButton({
    super.key,
    this.color,
    this.size = 15,
  });
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
      ),
    );
  }
}
