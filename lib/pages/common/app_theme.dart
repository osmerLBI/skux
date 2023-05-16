import 'package:flutter/material.dart';
import 'package:span_mobile/common/platform.dart';
import 'package:span_mobile/pages/skux/skux_theme.dart';

class AppTheme extends StatelessWidget {
  final Widget child;

  const AppTheme({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.SKUX) {
      return SkuxTheme(
        child: child,
      );
    }
    return child;
  }
}
