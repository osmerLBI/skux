import 'package:flutter/material.dart';
import 'package:span_mobile/common/util.dart';

class UnFocusWidget extends StatefulWidget {
  final Widget child;

  const UnFocusWidget({Key key, this.child}) : super(key: key);

  @override
  State<UnFocusWidget> createState() => _UnFocusWidgetState();
}

class _UnFocusWidgetState extends State<UnFocusWidget> {
  @override
  void initState() {
    Util.postFrame((p0) async {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // use GestureDetecot will make Semantics sortkey disable.
    return widget.child;
  }
}
