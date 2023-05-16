// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:flutter/foundation.dart';
import 'package:stack_trace/stack_trace.dart';

enum VLogMode {
  debug, // 💚 DEBUG
  warning, // 💛 WARNING
  info, // 💙 INFO
  error, // ❤️ ERROR
}

String VLog(dynamic msg, {VLogMode mode = VLogMode.debug, String tag = ''}) {
  if (kReleaseMode) {
    return "";
  }
  var chain = Chain.current(); // Chain.forTrace(StackTrace.current);

  chain =
      chain.foldFrames((frame) => frame.isCore || frame.package == "flutter");
  final frames = chain.toTrace().frames;
  final idx = frames.indexWhere((element) => element.member == "VLog");
  if (idx == -1 || idx + 1 >= frames.length) {
    return "";
  }
  final frame = frames[idx + 1];

  var modeStr = "";
  switch (mode) {
    case VLogMode.debug:
      modeStr = "vitta - DEBUG";
      break;
    case VLogMode.warning:
      modeStr = "vitta - WARNING";
      break;
    case VLogMode.info:
      modeStr = "vitta - INFO";
      break;
    case VLogMode.error:
      modeStr = "vitta - ERROR";
      break;
  }

  final printStr =
      "$modeStr ${frame.uri.toString().split("/").last}(${frame.line}) - $msg ";
  print('-------- $tag start --------');
  print(printStr);
  print('-------- $tag end --------');
  return printStr;
}
