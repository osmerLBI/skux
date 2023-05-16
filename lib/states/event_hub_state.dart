import 'package:flutter/material.dart';
import 'package:span_mobile/mixins/event_hub_mixin.dart';

abstract class EventHubState<T extends StatefulWidget> extends State<T>
    with EventHubMixin {
  void bindSetStateEvent(String event) {
    bindEvent(event, (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    unbindEvents();
    super.dispose();
  }
}
