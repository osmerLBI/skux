import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:span_mobile/common/util.dart';

class DebugWidget extends StatefulWidget {
  const DebugWidget({Key key, this.child}) : super(key: key);
  final Widget child;

  @override
  _DebugWidgetState createState() => _DebugWidgetState();
}

class _DebugWidgetState extends State<DebugWidget> {
  int _debugCount = 0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.child ??
          SvgPicture.asset('assets/image/spendr/spendr_logo.svg'),
      onTap: _debugMode,
    );
  }

  void _debugMode() {
    _debugCount++;
    Util.log(_debugCount.toString());
    if (_debugCount > (Util.isDev() ? 2 : 30)) {
      Util.showTestPage(
        context: context,
        force: true,
      );
      _debugCount = 0;
    }
  }
}
