import 'dart:async';

import 'package:span_mobile/common/util.dart';

mixin EventHubMixin {
  final List<StreamSubscription> _eventHubs = <StreamSubscription>[];

  void bindEvent(String event, void Function(dynamic) callback) {
    _eventHubs.add(Util.eventHub.on(event, callback));
  }

  void unbindEvents() {
    for (StreamSubscription ss in _eventHubs) {
      ss.cancel();
    }
  }
}
