import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:span_mobile/common/util.dart';

class LocalizeJsLoader extends AssetLoader {
  List<String> all;
  String prefix;
  bool missing;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    prefix = path + '/localize';
    await loadAll();
    Map<String, dynamic> content = await loadFile(locale);
    return parseContent(content);
  }
  
  Future loadAll() async {
    if (all != null) {
      return;
    }
    final Map<String, dynamic> map =
        json.decode(await rootBundle.loadString('AssetManifest.json'));
    all = map.keys
        .where((String k) => k.startsWith(prefix))
        .toList();
  }

  Future<Map<String, dynamic>> loadFile(Locale locale) async {
    String lo = locale.toLanguageTag();
    String path = '$prefix-$lo-phrases.json';
    if (!all.contains(path)) {
      Util.log('Missing localization file: ' + path);
      path = all[0];
      missing = true;
    } else {
      missing = false;
    }
    return json.decode(await rootBundle.loadString(path));
  }

  Map<String, dynamic> parseContent(Map<String, dynamic> map) {
    Map<String, dynamic> result = {};
    if (map.containsKey('dictionary')) {
      List<dynamic> dict = map['dictionary'];
      for (Map di in dict) {
        if (di.containsKey('translation')) {
          di['translation'].forEach((String key, value) {
            if (missing) {
              result[key] = key;
            } else if (value is Map && value.containsKey('value')) {
              result[key] = value['value'];
            } else {
              result[key] = key;
            }
          });
        }
      }
    }
    return result;
  }
}