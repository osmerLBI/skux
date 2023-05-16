import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:span_mobile/common/util.dart';

class DioResponse {
  bool success = false;
  String message;
  dynamic data;
  DioError error;

  DioResponse({this.success = false, this.message, this.data});

  DioResponse.fromResponse(Response response, {bool parseData = true}) {
    try {
      Map<String, dynamic> resp;
      if (response.data is String) {
        resp = json.decode(response.data.toString());
      } else if (response.data is Map) {
        resp = response.data;
      }
      if (!resp.containsKey('success')) {
        message = response.data.toString();
      } else {
        success = resp['success'] ?? false;
        message = resp['message'];
        data = resp['data'];
      }
    } on DioError catch (e) {
      message = Util.logDioError(e);
    } catch (e, callStack) {
      Util.log(e);
      Util.log(callStack);
      message = e.toString();
    }

    if (parseData) {
      _parseData();
    }

    if (success == false && message == null && data is String) {
      message = data;
    }
  }

  void _parseData() {
    if (data is String) {
      try {
        data = json.decode(data);
      } catch (e) {
        Util.printDebug(e);
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }

  bool isSuccess() {
    return success == true;
  }

  bool isSuccessMapData() {
    return success && data is Map;
  }

  bool isSuccessListData() {
    return success && data is List;
  }

  bool isSuccessNotFound() {
    return success && data == 'NotFound';
  }

  bool isCancelled() {
    return error != null && error.type == DioErrorType.cancel;
  }
}
