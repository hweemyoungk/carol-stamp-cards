import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';

class BlueprintInfo extends StatelessWidget {
  const BlueprintInfo({
    super.key,
    required this.blueprint,
    required this.textColor,
  });

  final Blueprint blueprint;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    Widget? image = blueprint.bgImageUrl == null
        // ? Image.memory(
        //     kTransparentImage,
        //     fit: BoxFit.contain,
        //   )
        ? null
        : Image.asset(
            blueprint.bgImageUrl!,
            fit: BoxFit.contain,
          );
    final blueprintDescText = Padding(
      padding: DesignUtils.basicWidgetEdgeInsets(),
      child: Text(
        blueprint.description,
        style: TextStyle(color: textColor),
      ),
    );
    final stampGrantCondTitle = Padding(
      padding: DesignUtils.basicWidgetEdgeInsets(),
      child: Text(
        'Stamp Grant Conditions',
        style:
            Theme.of(context).textTheme.titleLarge!.copyWith(color: textColor),
      ),
    );
    final stampGrantCondDescText = Padding(
      padding: DesignUtils.basicWidgetEdgeInsets(),
      child: Text(
        blueprint.stampGrantCondDescription,
        style: TextStyle(color: textColor),
      ),
    );
    final expirationDateTitle = Padding(
      padding: DesignUtils.basicWidgetEdgeInsets(),
      child: Text(
        'Expiriration Date',
        style:
            Theme.of(context).textTheme.titleLarge!.copyWith(color: textColor),
      ),
    );
    final expirationDateDescText = Padding(
      padding: DesignUtils.basicWidgetEdgeInsets(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatDateTime(blueprint.expirationDate),
            style: TextStyle(color: textColor),
          ),
          Text(
            '(${formatRemaining(blueprint.expirationDate.difference(DateTime.now()))})',
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    );
    return Column(
      children: [
        if (image != null) image,
        blueprintDescText,
        stampGrantCondTitle,
        stampGrantCondDescText,
        expirationDateTitle,
        expirationDateDescText,
      ],
    );
  }
}
