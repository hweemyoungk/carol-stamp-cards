import 'package:carol/utils.dart';
import 'package:flutter/material.dart';

class RequiredFieldLabel extends StatelessWidget {
  final Text labelText;

  const RequiredFieldLabel(this.labelText, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        labelText,
        const SizedBox(width: 4),
        DesignUtils.requiredFieldLabelSuffixText,
      ],
    );
  }
}
