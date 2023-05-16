import 'package:logger/logger.dart';
import 'package:span_mobile/common/util.dart';

class CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (!Util.isWebRelease()) {
      return true;
    }
    return event.level.index >= Logger.level.index;
  }
}
