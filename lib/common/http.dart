// make dio as global top-level variable

import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_log/interceptor/dio_log_interceptor.dart';
import 'package:span_mobile/common/platform.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/i18n/locale_data.dart';

Dio dio = Dio();

class Http {
  static void init() {
    dio.options.connectTimeout = 120000;
    dio.options.receiveTimeout = 120000;

    dio.interceptors.add(DioLogInterceptor());

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          if (!options.headers.containsKey('x-token')) {
            var tokenString = (Util.token ?? Util.tempToken) ?? '';
            if (options.uri.toString().endsWith('/user/profile')) {
              Util.log('Token: $tokenString');
            }
            options.headers['x-token'] = tokenString;
          }

          try {
            if (!options.headers.containsKey('x-i18n')) {
              LocaleData ld = LocaleData.current();
              if (ld != null) {
                options.headers['x-i18n'] = ld.key;
              }
            }
          } catch (e) {
            Util.log(e, tag: 'Failed to attach additional x-i18n http header');
          }

          try {
            if (!options.headers.containsKey('x-environment')) {
              options.headers['x-environment'] =
                  jsonEncode(Util.getEnvironment());
            }
          } catch (e) {
            Util.log(e,
                tag: 'Failed to attach additional environment http header');
          }

          if (platform != null) {
            platform.addRequestInterceptor(options);
          }

          return handler.next(options);
        },
      ),
    );

    var cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
  }
}
