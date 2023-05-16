import 'package:span_mobile/common/util.dart';

abstract class Signature {
  Map<String, dynamic> toJson();

  String getSignature() {
    return Util.signature(toJson());
  }
}
