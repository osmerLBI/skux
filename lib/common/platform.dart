// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:span_mobile/common/package.dart';
import 'package:span_mobile/common/skux/skux_platform.dart';
import 'package:span_mobile/i18n/locale_data.dart';

Platform platform;

class Platform {
  static bool TRANSFER_MEX = false;
  static bool SPENDR = false;
  static bool SKUX = false;

  static void init() {
    Package.init(); // Initialize the active platform here

    if (Platform.SKUX) {
      platform = SkuxPlatform();
    } else {
      platform = Platform();
    }
  }

  String apiPrefix() {
    return "";
  }

  String name() {
    return 'SKUx';
  }

  String key() {
    return 'SKUx';
  }

  MaterialColor swatchColor() {
    return Colors.blue;
  }

  Locale fallbackLocale() {
    return const Locale('en');
  }

  String productionUrl() {
    return 'https://skux.virtualcards.us';
  }

  String stagingUrl() {
    return 'https://skux-test.virtualcards.us';
  }

  List<String> localeKeys() {
    return ['en'];
  }

  Map<String, String> localeItem(Map<String, String> item) {
    return item;
  }

  List<LocaleData> localeData() {
    List<String> keys = localeKeys();
    return LocaleData.ALL.where((Map<String, String> element) {
      return keys.contains(element['key']);
    }).map((Map<String, String> element) {
      return LocaleData.create(localeItem(element));
    }).toList();
  }

  List<Locale> locales() {
    return localeData().map((LocaleData data) => data.locale()).toList();
  }

  List<Map<String, String>> testUsers() {
    return [];
  }

  void addRequestInterceptor(RequestOptions options) {}

  void onLogOut() async {}
}
