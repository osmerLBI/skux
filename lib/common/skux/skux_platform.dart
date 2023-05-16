import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:span_mobile/common/platform.dart';
import 'package:span_mobile/common/skux/skux_info.dart';
import 'package:span_mobile/common/util.dart';

class SkuxPlatform extends Platform {
  @override
  String apiPrefix() {
    return "/skux";
  }

  @override
  String name() {
    return 'SKUx';
  }

  @override
  String key() {
    return 'skux';
  }

  @override
  String productionUrl() {
    return 'https://skux-test.virtualcards.us';
  }

  @override
  String stagingUrl() {
    return 'https://skux-test.virtualcards.us';
  }

  @override
  Locale fallbackLocale() {
    return const Locale('en');
  }

  @override
  MaterialColor swatchColor() {
    return const MaterialColor(
      0xFF00DE00,
      <int, Color>{
        50: Color(0xFFEEFFEE),
        100: Color(0xFFCCFFCC),
        200: Color(0xFF99F699),
        300: Color(0xFF66F066),
        400: Color(0xFF33E633),
        500: Color(0xFF00DE00),
        600: Color(0xFF00C000),
        700: Color(0xFF00A000),
        800: Color(0xFF009000),
        900: Color(0xFF006000),
      },
    );
  }

  @override
  List<String> localeKeys() {
    return ['en', 'es'];
  }

  @override
  Map<String, String> localeItem(Map<String, String> item) {
    if (item['key'] == 'es') {
      Map<String, String> newItem = <String, String>{};
      newItem.addAll(item);
      newItem['name'] = 'Español (México)';
    }
    return item;
  }

  @override
  List<Map<String, String>> testUsers() {
    return [
      {'name': 'vitta', 'email': 'vitta3@yopmail.com', 'password': 'Skux1234'},
    ];
  }

  @override
  void addRequestInterceptor(RequestOptions options) {
    String suffix = '';

    Util.log(' --- request headers --- ' +
        suffix +
        '\n * token: ' +
        options.headers['x-token']);
  }

  @override
  void onLogOut() {
    Util.clear(
      exceptPref: [],
    );
    SkuxInfo.clear();
  }
}
