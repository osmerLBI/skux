import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:span_mobile/common/style.dart';

enum ColoredChipType {
  positive,
  negative,
  doing,
  warning,
  other,
}

class ColoredChip extends StatelessWidget {
  final String text;
  final ColoredChipType type;
  final double fontSize;
  final VoidCallback onPressed;
  final MaterialTapTargetSize targetSize;
  final bool labelOnly;

  const ColoredChip({
    Key key,
    @required this.text,
    this.type = ColoredChipType.other,
    this.fontSize = 15,
    this.onPressed,
    this.targetSize,
    this.labelOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    Color bgColor = style.primaryColor;
    Color textColor = Colors.white;
    if (type == ColoredChipType.positive) {
      bgColor = style.lightSuccessColor;
      textColor = style.successColor;
    } else if (type == ColoredChipType.negative) {
      bgColor = style.lightErrorColor;
      textColor = style.errorColor;
    } else if (type == ColoredChipType.doing) {
      bgColor = style.lightBlueColor;
      textColor = style.blueColor;
    } else if (type == ColoredChipType.warning) {
      bgColor = style.lightWarningColor;
      textColor = style.warningColor;
    } else {
      bgColor = Colors.grey[200];
      textColor = Colors.black87;
    }
    Widget label = Text(
      tr(text),
      style: textTheme.titleMedium.copyWith(
        fontSize: fontSize,
        fontFamily: labelOnly ? style.fontFamily4 : style.fontFamily5,
        color: textColor,
      ),
    );
    if (labelOnly) {
      return label;
    }

    bool small = targetSize == MaterialTapTargetSize.shrinkWrap;
    EdgeInsets padding = small
        ? const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 0,
          )
        : null;

    if (onPressed == null) {
      return Chip(
        backgroundColor: bgColor,
        label: label,
        padding: padding,
        materialTapTargetSize: targetSize,
      );
    }

    return ActionChip(
      backgroundColor: bgColor,
      label: label,
      labelPadding: padding,
      materialTapTargetSize: targetSize,
      onPressed: onPressed,
    );
  }
}
