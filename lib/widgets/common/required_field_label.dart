import 'package:carol/utils.dart';
import 'package:flutter/material.dart';

class RequiredFieldLabel extends StatelessWidget {
  final Widget labelText;

  const RequiredFieldLabel(this.labelText, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(child: labelText),
        const SizedBox(width: 4),
        DesignUtils.requiredFieldLabelSuffixText,
      ],
    );
  }
}
