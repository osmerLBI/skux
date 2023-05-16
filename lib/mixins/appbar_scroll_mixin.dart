import 'package:flutter/material.dart';

mixin AppBarScrollMixin<T extends StatefulWidget> on State<T> {
  double appBarElevation = 0;

  Widget appBarScrollNotificationListener({
    Widget child,
    double elevation = 8,
  }) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (ScrollEndNotification notification) {
        double p = notification.metrics.pixels;
        setState(() {
          appBarElevation = p > 0 ? elevation : 0;
        });
        return true;
      },
      child: child,
    );
  }
}
