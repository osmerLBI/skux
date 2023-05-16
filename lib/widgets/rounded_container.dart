import 'package:flutter/material.dart';
import 'package:span_mobile/common/util.dart';

class RoundedContainer extends StatefulWidget {
  final Widget child;
  final BoxConstraints constraints;

  const RoundedContainer({Key key, this.child, this.constraints})
      : super(key: key);

  @override
  _RoundedContainerState createState() => _RoundedContainerState();
}

class _RoundedContainerState extends State<RoundedContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: widget.constraints,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: Util.radius(20),
        ),
        child: widget.child,
      ),
    );
  }
}
