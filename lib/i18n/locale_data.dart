import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:span_mobile/common/platform.dart';
import 'package:span_mobile/common/util.dart';

class LocaleData {
  final String key;
  final String iso;
  final String name;
  final String language;

  LocaleData(this.key, this.iso, this.name, this.language);

  Locale locale() {
    List<String> ps = key.split('-');
    return Locale(ps[0], ps.length > 1 ? ps[1] : null);
  }

  bool isLocale(Locale locale) {
    if (locale.countryCode == null) {
      return language == locale.languageCode;
    }
    return key == locale.languageCode + '-' + locale.countryCode;
  }

  static LocaleData create(Map<String, String> map) {
    return LocaleData(map['key'], map['iso'], map['name'], map['language']);
  }

  static LocaleData current() {
    List<LocaleData> all = platform.localeData();
    Locale locale = EasyLocalization.of(Util.context).locale;
    for (LocaleData ld in all) {
      if (locale.languageCode == ld.language) {
        return ld;
      }
    }
    return all.firstWhere(
          (element) => element.language == 'en',
          orElse: () => null,
        ) ??
        all.first;
  }

  // ignore: constant_identifier_names
  static const List<Map<String, String>> ALL = [
    {'key': 'en', 'iso': 'us', 'name': 'English', 'language': 'en'},
    {'key': 'es', 'iso': 'mx', 'name': 'Español', 'language': 'es'},
  ];
}
