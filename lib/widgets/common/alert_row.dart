import 'package:flutter/material.dart';

class AlertRow extends StatelessWidget {
  const AlertRow({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.errorContainer,
          ),
        ),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }
}
