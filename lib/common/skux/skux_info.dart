// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/models/Skux/user.dart';
import 'package:span_mobile/pages/common/vlog.dart';
import 'package:span_mobile/store/skux_user_store.dart';

enum ClickPage {
  profile,
}

class SkuxInfo {
  // constants
  static const String phone = '(855) 879-8344';
  static const String phone_number = '+528558798344';
  static const String email = 'info@transfermex.com';
  static const int confirm_seconds = 300; // 5 * 60
  static const String dateTimeFormat = 'MMM d, yyyy';
  static String cardNumber = '';
  static ClickPage clickPage;

  static SkuxUser _user;
  static File _file;
  static Map lastViewedOffer;

  // events
  static const String inactivity_timer_event = 'skux_init_inactivity_timer';
  static void clear() {
    user = null;
  }

  static SkuxUser get user {
    if (_user == null) {
      String u = Util.pref.getString('user');
      if (u != null) {
        Map map = jsonDecode(u);
        if (map != null) {
          _user = SkuxUser.fromJson(map);
        }
      }
    }
    _user ??= SkuxUser();
    return _user;
  }

  static set user(SkuxUser user) {
    _user = user;
    if (user == null) {
      Util.pref.remove('user');
    } else {
      Util.pref.setString('user', jsonEncode(user.toJson()));
    }
  }

  static Future<File> clearRecentViewed() async {
    _file ??= await _recentViewedFile;
    try {
      await _file.delete();
    } catch (e) {
      if (e.runtimeType is PathNotFoundException) {
        VLog(e.toString());
      }
    }
    return _file;
  }

  static Future<File> get _recentViewedFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/recent_viewed.json');
  }

  static Future<File> writeRecentViewed(String offerId) async {
    _file ??= await _recentViewedFile;
    String uid = userStore.user.id.toString();
    String content = await readRecentViewed();
    Map data;
    try {
      data = jsonDecode(content);
    } catch (e) {
      data = {};
    }
    List currentUserViewed = data[uid] ?? [];
    if (currentUserViewed.contains(offerId)) {
      return null;
    } else {
      currentUserViewed.add(offerId);
      data[uid] = currentUserViewed;
      return await _file.writeAsString(jsonEncode(data));
    }
  }

  static Future<String> readRecentViewed() async {
    try {
      _file ??= await _recentViewedFile;
      String contents = await _file.readAsString();
      return contents;
    } catch (e) {
      VLog(e);
      return "";
    }
  }

  static Future<List> getCurrentRecentViewed() async {
    try {
      String contents = await readRecentViewed();
      Map data = jsonDecode(contents);
      return data[userStore.user.id.toString()] ?? [];
    } catch (e) {
      VLog(e);
      return [];
    }
  }

  static bool get haveReadRecentViewed {
    if (userStore.user == null) {
      return false;
    }
    return Util.pref.getBool('${userStore.user.id.toString}_haveReadRecentViewed');
  }

  static set haveReadRecentViewed(bool value) {
    if (value == null) {
      Util.pref.remove('${userStore.user.id.toString}_haveReadRecentViewed');
      return;
    }
    Util.pref.setBool('${userStore.user.id.toString}_haveReadRecentViewed', value);
  }

  static String get lastOfferId {
    return Util.pref.getString('${userStore.user.id.toString}_offer');
  }

  static set lastOfferId(String value) {
    if (value == null) {
      Util.pref.remove('${userStore.user.id.toString}_offer');
      return;
    }
    Util.pref.setString('${userStore.user.id.toString}_offer', value);
  }

  static bool get hasClaimedOfferSuccess {
    return Util.pref.getBool('hasClaimedOfferSuccess');
  }

  static set hasClaimedOfferSuccess(bool value) {
    if (value == null) {
      Util.pref.remove('hasClaimedOfferSuccess');
      return;
    }
    Util.pref.setBool('hasClaimedOfferSuccess', value);
  }

  // static void skuxLogin(String phone, String code) async {
  //   if (ObjectUtil.isEmpty(code) || ObjectUtil.isEmpty(phone)) {
  //     return;
  //   }
  //   Map params = {
  //     'phone': '+1' + phone,
  //     'code': code,
  //   };

  //   DioResponse resp =
  //       await Util.dioRequest(url: SKUxAPI.verifySMS, data: params);
  //   if (resp.success) {
  //     Util.tempToken = resp.data['token'];
  //     DioResponse currentResp = await Util.dioRequest(
  //         url: SKUxAPI.profileUrl, method: 'get', loading: true);
  //     if (currentResp.isSuccess()) {
  //       if (currentResp.data['uuid'] == userStore.user.id) {
  //         Util.token = Util.tempToken;
  //         VLog('skux user token getting successful ${Util.token}',
  //             mode: VLogMode.error);
  //       } else {
  //         VLog('skux user info does not match with the graphql user',
  //             mode: VLogMode.error);
  //       }
  //     } else {
  //       VLog('get skux user info error', mode: VLogMode.error);
  //     }
  //   } else {
  //     VLog('login skux error', mode: VLogMode.error);
  //   }
  // }
}
