import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class BlueprintInfo extends StatelessWidget {
  const BlueprintInfo({
    super.key,
    required this.blueprint,
    required this.textColor,
  });

  final StampCardBlueprint blueprint;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    Widget image = blueprint.bgImageUrl == null
        ? Image.memory(
            kTransparentImage,
            fit: BoxFit.contain,
          )
        : Image.asset(
            blueprint.bgImageUrl!,
            fit: BoxFit.contain,
          );
    final blueprintDescText = Padding(
      padding: Utils.basicWidgetEdgeInsets(),
      child: Text(
        blueprint.description,
        style: TextStyle(color: textColor),
      ),
    );
    final stampGrantCondTitle = Padding(
      padding: Utils.basicWidgetEdgeInsets(),
      child: Text(
        'Stamp Grant Conditions',
        style:
            Theme.of(context).textTheme.titleLarge!.copyWith(color: textColor),
      ),
    );
    final stampGrantCondDescText = Padding(
      padding: Utils.basicWidgetEdgeInsets(),
      child: Text(
        blueprint.stampGrantCondDescription,
        style: TextStyle(color: textColor),
      ),
    );
    return Column(
      children: [
        image,
        blueprintDescText,
        stampGrantCondTitle,
        stampGrantCondDescText,
      ],
    );
  }
}
