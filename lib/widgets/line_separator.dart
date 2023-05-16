import 'package:flutter/material.dart';
import 'package:span_mobile/common/style.dart';

class LineSeparator extends StatelessWidget {
  final bool high;
  final Color color;

  const LineSeparator({Key key, this.high = false, this.color = Style.bgColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      height: high ? 15 : 1,
    );
  }
}
