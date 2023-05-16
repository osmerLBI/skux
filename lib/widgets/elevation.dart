import 'package:flutter/material.dart';

class Elevation extends StatelessWidget {
  final double elevation;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Widget child;

  const Elevation({
    Key key,
    this.elevation = 4,
    this.child,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          if (elevation > 0)
            BoxShadow(
              color: Colors.grey[300],
              spreadRadius: 0,
              blurRadius: elevation / 2,
              offset: Offset(0, elevation / 2),
            ),
        ],
      ),
      child: child,
    );
  }
}
