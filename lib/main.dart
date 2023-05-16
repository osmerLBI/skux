import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:span_mobile/common/http.dart';
import 'package:span_mobile/common/platform.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/pages/app.dart';
import 'package:span_mobile/pages/common/vlog.dart';
import 'package:span_mobile/pages/skux/auth/LoginFormState.dart';
import 'package:span_mobile/pages/skux/auth/AuthenticationState.dart';
import 'package:uni_links/uni_links.dart';
import 'package:firebase_core/firebase_core.dart';

import 'common/util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await EasyLocalization.ensureInitialized();

  Http.init();
  Platform.init();

  Style.init();
  await Util.init();

  Future<void> _initUniLinks() async {
    try {
      await getInitialLink();
    } on PlatformException {
      VLog('Failed to get initial link.');
    }
  }

  await _initUniLinks();

  var prefs = await SharedPreferences.getInstance();

  final String refreshToken = prefs.getString('refreshToken');
  final String authenticationToken = prefs.getString('authenticationToken');
  final int expirationTimestamp = prefs.getInt('expirationTimestamp');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthenticationState()),
      ChangeNotifierProvider(create: (context) => LoginFormState()),
    ],
    child: App(
      refreshToken: refreshToken,
      authenticationToken: authenticationToken,
      expirationTimestamp: expirationTimestamp,
    ),
  ));
}
