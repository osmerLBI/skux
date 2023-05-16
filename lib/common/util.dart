// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secure;
import 'package:http_parser/http_parser.dart' as hp;
import 'package:jiffy/jiffy.dart';
import 'package:logger/logger.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:mime/mime.dart';
import 'package:money2/money2.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:span_mobile/common/http.dart';
import 'package:span_mobile/common/platform.dart' as span;
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/i18n/locale_data.dart';
// import 'package:span_mobile/models/dio_response.dart';
import 'package:span_mobile/models/signature.dart';
import 'package:span_mobile/pages/common/custom_log_filter.dart';
import 'package:span_mobile/pages/common/test_page.dart';
import 'package:span_mobile/states/can_leave_state.dart';
import 'package:uuid/uuid.dart';

enum BiometricResult { granted, denied, unavailable }

class Util {
  // ignore: todo
  // TODO: Change to false when releasing the app
  static const TESTING = true;
  static const DEBUG_PWD = 'pH89e76kbsMhhP';

  static BuildContext context;
  static SharedPreferences pref;
  static secure.FlutterSecureStorage storage;
  static Logger logger;
  static Directory docDir;
  static EventHub eventHub = EventHub();
  static PackageInfo packageInfo;
  static String google_map_places_api_key;

  static String serverUrl;
  static String tempToken;
  static String graphQLTempToken;
  static Map<String, dynamic> _environment;

  static String pinToken;
  static bool biometricsLogin;
  static bool consumerPinVerify;

  static Currency usd;
  static Currency mxn;

  static Map transactionTypes = {};

  static int currentIndex;

  static String deviceId = '';

  static bool versionDialogPopup = false;

  static String get refreshToken {
    return Util.pref.getString('refreshToken');
  }

  static set refreshToken(String value) {
    if (value == null) {
      Util.pref.remove('refreshToken');
      return;
    }
    Util.pref.setString('refreshToken', value);
  }

  static String get token {
    return Util.pref.getString('token');
  }

  static set token(String value) {
    if (value == null) {
      Util.pref.remove('token');
      return;
    }
    Util.pref.setString('token', value);
  }

  static String get graphQLRefreshToken {
    return Util.pref.getString('graphQLRefreshToken');
  }

  static set graphQLRefreshToken(String value) {
    if (value == null) {
      Util.pref.remove('graphQLRefreshToken');
      return;
    }
    Util.pref.setString('graphQLRefreshToken', value);
  }

  static String get graphQLToken {
    return Util.pref.getString('graphQLToken');
  }

  static set graphQLToken(String value) {
    if (value == null) {
      Util.pref.remove('graphQLToken');
      return;
    }
    Util.pref.setString('graphQLToken', value);
  }

  static Future init() async {
    Logger.level = Level.error;

    if (!kIsWeb && Platform.isIOS) {
      google_map_places_api_key = 'AIzaSyAuO8mUUuV-Uvm-QsOhfupKqb9mT0sGalY';
    } else if (!kIsWeb && Platform.isAndroid) {
      google_map_places_api_key = 'AIzaSyDNCqtrOru4ssnP8Rhxtn7IWmmn5e9tVi8';
    } else if (kIsWeb) {
      google_map_places_api_key = 'AIzaSyCtjFRds8BqTZtZjeULsaQkDKRaIW16aCw';
    }

    if (TESTING && !kIsWeb) {
      Logger.level = Level.verbose;
      Future.delayed(const Duration(seconds: 2), () {
        LogConsole.init();
        ShakeDetector.autoStart(
          shakeThresholdGravity: Platform.isIOS ? 3.8 : 1.8,
          onPhoneShake: () {
            // showTestPage();
          },
        );
      });
    }

    logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        lineLength: 80,

        // Android Studio don't have color support in the debug console
        // colors: false,
      ),
      filter: CustomLogFilter(),
    );

    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = true;

    CommonCurrencies cs = CommonCurrencies();
    usd = cs.usd;
    mxn = cs.mxn;
    Currencies().registerList([]);

    pref = await SharedPreferences.getInstance();
    // serverUrl = span.platform.productionUrl();
    if (serverUrl == null) {
      String prefUrl = pref.getString('serverUrl');
      if (prefUrl == null) {
        if (isDebug() || TESTING) {
          serverUrl = span.platform.stagingUrl();
        } else {
          serverUrl = span.platform.productionUrl();
        }
      } else {
        serverUrl = prefUrl;
      }
    }

    packageInfo = await PackageInfo.fromPlatform();
    if (!kIsWeb) {
      storage = const secure.FlutterSecureStorage();
      docDir = await getApplicationDocumentsDirectory();
    }

    await updateSystemLocale();
  }

  static void setContext(BuildContext c) {
    BuildContext oldContext = context;
    context = c ?? context;
    if (oldContext == null && c != null) {
      updateSystemLocale();
    }
  }

  static Future<dynamic> readSecureStorage(String key) {
    if (storage == null) {
      String value = pref.get(key);
      if (value == null) {
        return null;
      }
      return Future.sync(() => jsonDecode(value));
    }
    return storage.read(key: key);
  }

  static Future writeSecureStorage(String key, dynamic value) async {
    if (storage == null) {
      return pref.setString(key, jsonEncode(value));
    }
    storage.write(key: key, value: value);
  }

  static void clear({
    List<String> exceptPref = const [],
    List<String> exceptSecure = const [],
  }) async {
    token = null;

    if (exceptPref.isEmpty) {
      pref.clear();
    } else {
      for (String key in pref.getKeys()) {
        if (!exceptPref.contains(key)) {
          pref.remove(key);
        }
      }
    }

    if (exceptSecure.isEmpty) {
      await storage.deleteAll();
    } else {
      var all = await storage.readAll();
      for (String key in all.keys) {
        if (!exceptSecure.contains(key)) {
          await storage.delete(key: key);
        }
      }
    }
  }

  static Future<void> updateSystemLocale([LocaleData ld]) async {
    if (context == null) {
      return;
    }
    ld ??= LocaleData.current();
    await EasyLocalization.of(context).setLocale(ld.locale());
    await Jiffy.locale(ld.key);
  }

  static void showTestPage({BuildContext context, bool force = false}) {
    if (!TESTING && !force) {
      return;
    }
    Util.push(
      builder: () {
        return const TestPage();
      },
      context: context,
    );
  }

  static void showTestPageSecurely({BuildContext context, bool force = false}) async {
    if (Util.isDebug()) {
      Util.showTestPage(
        context: context,
        force: force,
      );
      return;
    }

    String psd = await Util.showPromptDialog(
      context: context,
      title: 'Enter Password For Debug',
      msg: 'Password',
      obscureText: true,
    );
    if (psd == Util.DEBUG_PWD) {
      Util.showTestPage(
        context: context,
        force: force,
      );
    }
  }

  static String getVersion() {
    if (packageInfo == null || packageInfo.version == null) {
      return '';
    }
    return 'Ver: ${packageInfo.version} (${packageInfo.buildNumber})';
  }

  static String getBundleId() {
    if (packageInfo == null || packageInfo.packageName == null) {
      return '';
    }
    return packageInfo.packageName;
  }

  static Map<String, dynamic> getEnvironment() {
    _environment ??= {
      'os': Platform.operatingSystem,
      'osv': Platform.operatingSystemVersion,
      'locale': Platform.localeName,
      'version': packageInfo.version,
      'build': packageInfo.buildNumber,
      'web': kIsWeb,
      // 'device': deviceId,
    };
    return _environment;
  }

  static bool isLandscape() {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait() {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static Widget widget() {
    return const SizedBox.shrink();
  }

  static Widget widgetIf(bool expression, WidgetBuilder widgetWhenTrue, [BuildContext context]) {
    return expression ? widgetWhenTrue(context ?? Util.context) : const SizedBox.shrink();
  }

  static Widget landscapeWidget(WidgetBuilder widgetWhenTrue, [BuildContext context]) {
    return isLandscape() ? widgetWhenTrue(context ?? Util.context) : const SizedBox.shrink();
  }

  static Widget portraitWidget(WidgetBuilder widgetWhenTrue, [BuildContext context]) {
    return isPortrait() ? widgetWhenTrue(context ?? Util.context) : const SizedBox.shrink();
  }

  static Text text(String text, {TextStyle style}) {
    return Text(tr(text), style: style);
  }

  static Color opacity(Color color, double opacity) {
    return Color.fromRGBO(color.red, color.green, color.blue, opacity);
  }

  static String initials(String firstName, String lastName) {
    firstName = firstName ?? '';
    lastName = lastName ?? '';
    String s = firstName.isEmpty ? '' : firstName.substring(0, 1);
    String e = lastName.isEmpty ? '' : lastName.substring(0, 1);
    return s + e;
  }

  static void toggleStatusBar(bool visible) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: visible ? SystemUiOverlay.values : []);
  }

  static void textFieldFixFocus(FocusNode textFieldFocusNode) {
    textFieldFocusNode.unfocus();
    textFieldFocusNode.canRequestFocus = false;

    Future.delayed(const Duration(milliseconds: 100), () {
      textFieldFocusNode.canRequestFocus = true;
    });
  }

  static void snackBar(
    String msg, {
    BuildContext context,
    Color color,
  }) {
    context = context ?? Util.context;
    ScaffoldMessengerState sm = ScaffoldMessenger.of(context);
    sm.removeCurrentSnackBar();
    sm.showSnackBar(SnackBar(
      content: Text(
        tr(msg),
      ),
      duration: duration(3000),
      backgroundColor: color ?? style.snackBarColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius(15),
      ),
    ));
  }

  static void snackBarSuccess([String msg = 'The operation completed successfully!', BuildContext context]) {
    snackBar(msg, color: style.successColor, context: context);
  }

  static void snackBarError(String msg, [BuildContext context]) {
    snackBar(msg, color: style.errorColor, context: context);
  }

  static void toast(
    String msg, {
    double seconds = 2,
    EasyLoadingToastPosition position = EasyLoadingToastPosition.bottom,
  }) {
    EasyLoading.showToast(
      tr(msg),
      duration: duration((seconds * 2500).round()),
      toastPosition: position,
      dismissOnTap: true,
      maskType: EasyLoadingMaskType.none,
    );
  }

  static void toastSuccess() {
    toast('The operation completed successfully!');
  }

  static void toastSaved() {
    toast('Saved successfully!');
  }

  static void showWipDialog({BuildContext context}) {
    BuildContext ctx = context ?? Util.context;
    showDialog<void>(
      context: ctx,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(tr('Info')),
          content: Text(tr('This feature is working in progress.')),
          actions: <Widget>[
            ElevatedButton(
              child: Text(tr('OK')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showSuccessDialog({
    BuildContext context,
    String title = 'Success',
    String msg = 'The operation completed successfully!',
  }) {
    return showMsgDialog(context: context, title: title, msg: msg);
  }

  static Future<void> showMsgDialog({
    BuildContext context,
    String title = 'Info',
    String msg = 'The operation completed successfully!',
  }) {
    BuildContext ctx = context ?? Util.context;
    return showDialog<void>(
      context: ctx,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Semantics(
            excludeSemantics: true,
            label: 'Alert ' + tr(title),
            child: Text(tr(title)),
          ),
          content: Text(tr(msg)),
          actions: <Widget>[
            ElevatedButton(
              child: Text(tr('OK')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showFormValidationDialog({BuildContext context, String title = 'Error', String msg}) {
    msg ??= 'Please fix the issues before submitting the form!';
    return showMsgDialog(context: context, title: title, msg: msg);
  }

  static Future<void> showErrorDialog({BuildContext context, String title = 'Error', String msg}) {
    msg ??= 'The operation failed!';
    return showMsgDialog(context: context, title: title, msg: msg);
  }

  static Future<void> showApiErrorDialog({BuildContext context, String title = 'Error', String msg}) {
    msg ??= 'Unknown error from API';
    return showMsgDialog(context: context, title: title, msg: msg);
  }

  static void showConfirmDialog({
    BuildContext context,
    String title = 'Confirm',
    String msg = 'Are you sure you want to continue?',
    String okText = 'OK',
    bool isDanger = false,
    Function() onOk,
    Function(BuildContext) onCancel,
    Function(BuildContext) onCreate,
  }) {
    BuildContext ctx = context ?? Util.context;
    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        if (onCreate != null) {
          onCreate(dialogContext);
        }
        return AlertDialog(
          title: Semantics(
            label: tr(title) + ' Dialog',
            excludeSemantics: true,
            header: true,
            child: Text(tr(title)),
          ),
          content: Text(tr(msg)),
          actions: <Widget>[
            TextButton(
              child: Text(
                tr('Cancel'),
                style: TextStyle(
                  color: const Color(0xFF707075),
                  fontFamily: style.fontFamily4,
                  decoration: TextDecoration.underline,
                ),
              ),
              onPressed: () {
                if (onCancel != null) {
                  onCancel(dialogContext);
                } else {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
            ElevatedButton(
              child: Text(tr(okText)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                backgroundColor: isDanger == true ? SkuxStyle.redColor : const Color(0xFF0674DB),
              ),
              onPressed: () async {
                if (onOk != null) {
                  await onOk();
                } else {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void showConfirmDeletionDialog(
      {BuildContext context,
      String title = 'Delete Item',
      String msg = 'Are you sure you want to delete this item?',
      String okText = 'Delete',
      Function() onOk,
      Function(BuildContext) onCancel}) {
    showConfirmDialog(context: context, title: title, msg: msg, okText: okText, onOk: onOk, onCancel: onCancel);
  }

  static void showConfirmDiscardDialog(
      {BuildContext context,
      String title = 'Confirm',
      String msg = 'Are you sure you want to leave? The changes will be discarded!',
      String okText = 'OK',
      Function() onOk,
      Function(BuildContext) onCancel}) {
    showConfirmDialog(context: context, msg: msg, okText: okText, onOk: onOk, onCancel: onCancel);
  }

  static Future<String> showPromptDialog({
    BuildContext context,
    String title = 'Prompt',
    String msg = 'Please enter the value:',
    bool clear = true,
    String value,
    bool obscureText = false,
  }) async {
    BuildContext ctx = context ?? Util.context;
    TextEditingController _ctrl = TextEditingController(text: value);
    FocusNode textFieldFocusNode = FocusNode();
    String result = await showDialog<String>(
      context: ctx,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(tr(title)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(tr(msg)),
              const SizedBox(height: 5),
              TextField(
                controller: _ctrl,
                autofocus: true,
                obscureText: obscureText,
                focusNode: textFieldFocusNode,
                decoration: InputDecoration(
                  suffixIcon: clear
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.black38,
                          onPressed: () {
                            Util.textFieldFixFocus(textFieldFocusNode);
                            _ctrl.text = '';
                            Navigator.of(dialogContext).pop('');
                          },
                        )
                      : null,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                tr('Cancel'),
                style: TextStyle(
                  color: Colors.black45,
                  fontFamily: style.fontFamily4,
                  decoration: TextDecoration.underline,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: Text(tr('OK')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(_ctrl.text);
              },
            ),
          ],
        );
      },
    );
    return result;
  }

  static BorderRadiusGeometry radius(double r) {
    return BorderRadius.all(Radius.circular(r));
  }

  static String uuid() {
    return const Uuid().v1();
  }

  static void loading({bool visible = true, VoidCallback onCancel, bool dismissOnTap}) {
    try {
      if (visible) {
        EasyLoading.show(dismissOnTap: dismissOnTap, status: 'Loading');
      } else {
        EasyLoading.dismiss();
      }
    } catch (error) {
      // reportError(error, stackTrace);
    }
  }

  static void printDebug(text) {
    if (!isWebRelease()) {
      // ignore: avoid_print
      print(text);
    }
  }

  static void logTrace() {
    log(StackTrace.current);
  }

  static void log(
    dynamic object, {
    String tag,
    Map<String, dynamic> context,
  }) {
    var method = logger == null ? print : logger.d;

    try {
      if (tag != null) {
        method(tag);
      }

      method(object);

      if (context != null) {
        method(context);
      }
    } catch (e) {
      printDebug(e);
    }
  }

  static logTime([String tag, Map<String, dynamic> context]) {
    String s = Jiffy().format();
    if (tag != null) {
      s += ' --- ' + tag;
    }
    logger.d(s);

    if (context != null) {
      logger.d(context);
    }
  }

  static String logDioError(DioError e) {
    logger.e('-------- Dio exception -------', e);
    printDebug(e.toString());
    String msg = e.error != null ? e.error.toString() : 'Dio error';
    if (e.response != null) {
      printDebug(e.response.data);
      printDebug(e.response.headers);
      printDebug(e.response.requestOptions);

      Map<String, dynamic> resp;
      if (e.response.data is String) {
        try {
          resp = json.decode(e.response.data.toString());
        } catch (e) {
          printDebug(e.toString());
        }
      } else if (e.response.data is Map) {
        resp = e.response.data;
      }
      if (resp != null && resp.containsKey('message')) {
        msg = resp['message'] ?? (e.error != null ? e.error.toString() : 'Unknown error');
      }
    } else {
      printDebug(e.requestOptions);
      printDebug(e.message);
      if (e.message != null) {
        msg = e.message;
      }
    }
    return msg;
  }

  static bool existInFormData(FormData data, String key) {
    for (MapEntry<String, dynamic> field in data.fields) {
      if (field.key == key) {
        return true;
      }
    }
    return false;
  }

//   static Future<DioResponse> dioRequest({
//     String method = 'POST',
//     @required String url,
//     var data,
//     Map<String, dynamic> queryParameters,
//     Options options,
//     bool loading = true,
//     bool parseData = true,
//     bool silent = false,
//     ProgressCallback onSendProgress,
//     CancelToken cancelToken,
//     BuildContext requestContext,
//   }) async {
//     DioResponse resp = DioResponse();
//     options ??= Options();
//     options.method = method;
//     options.sendTimeout = options.sendTimeout ?? 600000;
//     options.receiveTimeout = options.receiveTimeout ?? 600000;

//     requestContext ??= context;

//     data ??= {};

//     bool logResponse = true;
//     cancelToken ??= CancelToken();

//     String fullUrl = '$serverUrl$url';
//     logTime('--- dio request --- $method: $fullUrl');
//     if (data is FormData) {
//       for (MapEntry<String, String> field in data.fields) {
//         logger.i(field.toString());
//       }

//       for (MapEntry<String, MultipartFile> field in data.files) {
//         logger.i({
//           'contentType': field.value.contentType.toString(),
//           'filename': field.value.filename,
//           'length': field.value.length,
//         });
//       }
//     } else if (data is Map) {
//       logger.i(data);
//     }

//     if (queryParameters != null) {
//       logger.i(queryParameters);
//     }

//     if (loading) {
//       Util.loading(onCancel: () {
//         cancelRequest(cancelToken);
//       });
//     }
//     try {
//       Response response = await dio.request(
//         fullUrl,
//         data: data,
//         queryParameters: queryParameters,
//         options: options,
//         onSendProgress: onSendProgress,
//         cancelToken: cancelToken,
//       );
//       if (response.data != null) {
//         logTime('--- dio response ---');
//         if (logResponse) {
//           printDebug(response.data.toString());
//           logTime('--- curl ---');
//           log(dio2curl(response.requestOptions));
//         }

//         resp = DioResponse.fromResponse(response, parseData: parseData);
//         if (logResponse) {
//           logger.i(resp.data);
//         }
//       }
//     } on DioError catch (e) {
//       resp.error = e;
//       resp.message = Util.logDioError(e);

//       if (e.error != null && e.error is SocketException) {
//         resp.message =
//             tr('The request failed. Please check your network connection!');
//       }

//       if (e.type == DioErrorType.cancel) {
//         silent = true;
//         toast(resp.message ?? tr('Task is cancelled.'));
//       }
//     }

//     if (isDebug()) {
// //      await Future.delayed(duration(1500));
//     }

//     if (loading) {
//       Util.loading(visible: false);
//     }
//     if (!resp.isSuccess() && silent == false) {
//       String msg = resp.message;
//       if (msg == null || msg.isEmpty) {
//         msg = tr('Unknown error from API');
//       }
//       Map data = resp.data;

//       if (data != null && data.containsKey('type')) {
//         final type = data['type'];
//         if (type == 'verify_email') {
//         } else {
//           showMsgDialog(context: requestContext, title: 'Error', msg: msg);
//         }
//       } else {
//         showMsgDialog(context: requestContext, title: 'Error', msg: msg);
//       }
//     }

//     return resp;
//   }

  static void cancelRequest(CancelToken cancelToken) {
    try {
      cancelToken?.cancel(tr('Operation is cancelled'));
    } catch (e) {
      Util.log(e, tag: 'Failed to cancel dio request');
      Util.loading(visible: false);
    }
  }

  static bool isUrl(String str) {
    if (str == null) {
      return false;
    }
    str = str.toLowerCase();
    return str.startsWith('http://') || str.startsWith('https://');
  }

  static int ensureInt(var v, [var defaultValue]) {
    if (v != null && v is String) {
      return int.tryParse(v);
    }
    if (defaultValue != null) {
      return defaultValue;
    }
    return v;
  }

  static bool isEmpty(var v) {
    if (v == null) {
      return true;
    }
    if (v is String && v.isEmpty) {
      return true;
    }
    if (v is int && v == 0) {
      return true;
    }
    return false;
  }

  static ensure(var value, var defaultValue) {
    if (isEmpty(value)) {
      return defaultValue;
    }
    return value;
  }

  static String str(String input, [String defaultValue = '']) {
    if (isEmpty(input)) {
      return defaultValue;
    }
    return input;
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static bool isWebRelease() {
    return isWeb() && !isDebug();
  }

  static bool isRelease() {
    return const bool.fromEnvironment('dart.vm.product');
  }

  static bool isDev() {
    return TESTING || isDebug();
  }

  static bool isTesting() {
    return TESTING && !isDebug();
  }

  static bool isDebug() {
    bool ret = false;
    assert(() {
      ret = true;
      return true;
    }());
    return ret;
  }

  static bool isProfile() {
    return !isRelease() && !isDebug();
  }

  static void focusNone([VoidCallback callback]) {
    FocusScope.of(context).unfocus();

    if (callback is Function) {
      callback();
    }
  }

  static void postFrame(void Function(Duration) callback, {List fieldsToValidate = const [], bool focusNone = false, Duration delay}) {
    void _execPostFrame(Duration duration) {
      callback(duration);

      for (var key in fieldsToValidate) {
        key.currentState.validate();
      }

      if (focusNone) {
        Util.focusNone();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      if (delay != null) {
        Future.delayed(delay, () {
          _execPostFrame(duration);
        });
        return;
      }
      _execPostFrame(duration);
    });
  }

  static String signature(var obj) {
    if (obj == null || obj is String) {
      return obj;
    }
    if (obj is Signature) {
      return obj.getSignature();
    }
    try {
      var encoded = json.encode(obj);
      return encoded.toString();
    } catch (e, stacks) {
      printDebug(e);
      printDebug(stacks);
      return obj.toString();
    }
  }

  static bool compareSig(var obj, String old) {
    String newSig = signature(obj);
    printDebug('--------- Compare signature --------');
    printDebug(old);
    printDebug(newSig);
    return newSig == old;
  }

  static bool canLeave(var entity, String oldEntitySig, {List<GlobalKey<CanLeaveState>> keys = const []}) {
    if (!Util.compareSig(entity, oldEntitySig)) {
      return false;
    }
    for (GlobalKey<CanLeaveState> key in keys) {
      if (key.currentState != null && !key.currentState.canLeave()) {
        return false;
      }
    }
    return true;
  }

  static Future<bool> simpleLeaveConfirm() {
    return leaveConfirm('a', 'b');
  }

  static Future<bool> leaveConfirm(var entity, String oldEntitySig, {List<GlobalKey<CanLeaveState>> keys = const []}) {
    Completer<bool> completer = Completer<bool>();

    bool isCanLeave = canLeave(entity, oldEntitySig, keys: keys);
    if (isCanLeave) {
      completer.complete(true);
    } else {
      Util.showConfirmDiscardDialog(onOk: () {
        completer.complete(true);
      });
    }

    return completer.future;
  }

  static Map<String, dynamic> removeNullFields(Map<String, dynamic> data) {
    Map<String, dynamic> result = {};
    data.forEach((String key, value) {
      if (value != null) {
        result[key] = value;
      }
    });
    return result;
  }

  static SystemUiOverlayStyle systemUiOverlayStyle() {
    return Platform.isIOS ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light;
  }

  static String validateRequired(String value) {
    if (value == null || value.isEmpty) {
      return tr('This field is required!');
    }
    return null;
  }

  static Duration duration([int milliseconds = 300]) {
    return Duration(milliseconds: milliseconds);
  }

  static NavigatorState navigator({BuildContext context}) {
    BuildContext ctx = context ?? Util.context;
    return Navigator.of(ctx);
  }

  static Future<Object> push({
    BuildContext context,
    @required Widget Function() builder,
    String name,
    bool fullscreenDialog = false,
  }) async {
    return navigator(context: context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return builder();
      },
      settings: RouteSettings(name: name),
      fullscreenDialog: fullscreenDialog,
    ));
  }

  static Rect innerAspectRect(double ratio, {Size size}) {
    size ??= MediaQuery.of(context).size;
    double ratioScreen = size.width / size.height;
    double left = 0;
    double top = 0;
    double width = size.width;
    double height = size.height;
    if (ratio > ratioScreen) {
      height = size.width / ratio;
      top = (size.height - height) / 2;
    } else {
      width = ratioScreen * size.height;
      left = (size.width - width) / 2;
    }
    return Rect.fromLTWH(left, top, width, height);
  }

  static Rect outerAspectRect(double ratio, {Size size}) {
    size ??= MediaQuery.of(context).size;
    double ratioScreen = size.width / size.height;
    double left = 0;
    double top = 0;
    double width = size.width;
    double height = size.height;
    if (ratio > ratioScreen) {
      width = ratio * size.height;
      left = (size.width - width) / 2;
    } else {
      height = size.width / ratioScreen;
      top = (size.height - height) / 2;
    }
    return Rect.fromLTWH(left, top, width, height);
  }

  static Future<String> buddyFile({@required String path, String suffix = 'thumbnail.jpg'}) async {
    String hash = sha1.convert(utf8.encode(path)).toString();
    Directory dir = await getTemporaryDirectory();
    return dir.path + '/${hash}_$suffix';
  }

  static bool containsAny(String main, List<Pattern> parts) {
    for (Pattern part in parts) {
      if (main.contains(part)) {
        return true;
      }
    }
    return false;
  }

  static Future<void> waitUntil(bool Function() checker) async {
    return Future.sync(() async {
      Completer completer = Completer();
      Timer.periodic(const Duration(milliseconds: 20), (Timer timer) {
        if (checker() == true) {
          timer.cancel();
          completer.complete();
        }
      });
      await completer.future;
    });
  }

  static Future<void> runUnless(bool Function() checker, VoidCallback run) async {
    await waitUntil(checker);
    return run();
  }

  static Map<String, dynamic> getPrefMap(String key) {
    String saved = Util.pref.getString(key);
    Map<String, dynamic> map;
    if (saved != null) {
      map = json.decode(saved);
    }
    return map;
  }

  static void savePrefMap(String key, Map<String, dynamic> map) {
    String saved = json.encode(map);
    Util.pref.setString(key, saved);
  }

  static List getPrefList(String key) {
    String saved = Util.pref.getString(key);
    List list;
    if (saved != null) {
      list = json.decode(saved);
    }
    return list;
  }

  static void savePrefList(String key, List list) {
    String saved = json.encode(list);
    Util.pref.setString(key, saved);
  }

  static Future<MultipartFile> multipartFile(path) {
    return MultipartFile.fromFile(
      path,
      contentType: hp.MediaType.parse(lookupMimeType(path)),
    );
  }

  static Color colorFromHex(String hex) {
    if (hex == null) {
      return null;
    }
    hex = hex.replaceFirst('#', '0x');
    return Color(int.parse(hex));
  }

  static String colorHex(Color color) {
    return '#' + color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
  }

  static Currency currency(String currency) {
    Currency cur = usd;
    if (currency == 'MXN') {
      cur = mxn;
    } else if (currency == 'CNY') {
      return CommonCurrencies().cny;
    } else if (currency != null && currency != 'USD') {
      throw 'Unknown currency: ' + currency;
    }
    return cur;
  }

  static String formatMoney(
    int minor, {
    String currency = 'USD',
    bool sign = false,
    bool withCurrency = true,
  }) {
    minor ??= 0;
    bool sub = minor < 0;
    String s = Money.fromInt(minor.abs(), code: currency).format('S###,###,###,###.00');
    if (withCurrency && currency != 'USD') {
      s += ' ' + currency;
    }
    if (sub) {
      s = '-' + s;
    } else if (sign) {
      s = '+' + s;
    }
    return s;
  }

  static int normalizeMoney(double major, [String currency = 'USD']) {
    major = major * 100;
    double rounded = double.parse(major.toStringAsFixed(Util.currency(currency).scale));
    Money m = Money.fromNum(rounded, code: currency);
    return (m.minorUnits.toInt() / 100).round();
  }

  static String formatTime(String iso, {String format = 'date'}) {
    if (iso == null || iso.isEmpty) {
      return '';
    }
    Jiffy j = Jiffy(iso);
    if (format == 'date') {
      if (EasyLocalization.of(context).locale.languageCode == 'es') {
        return j.yMd;
      }
      return j.yMMMd;
    }
    if (format == 'datetime') {
      return j.yMMMMdjm;
    }
    return j.format(format);
  }

  static Color moneyColor(int minor) {
    minor ??= 0;
    if (minor > 0) {
      return style.successColor;
    }
    if (minor < 0) {
      return style.errorColor;
    }
    return Theme.of(context).textTheme.bodyLarge.color;
  }

  static String fullName(Map<String, dynamic> data) {
    if (data == null) {
      return '';
    }
    return ((data['firstName'] ?? '') + ' ' + (data['lastName'] ?? '')).trim();
  }

  static List<String> validatePhoneNumber(String number) {
    if (number == null || !number.startsWith('+')) {
      return [number];
    }
    List<String> parts = number.split(' ');
    if (parts == null || parts.length <= 1) {
      return [number];
    }
    return [
      parts[0],
      parts.sublist(1).join(),
    ];
  }

  static String formatAPIDate(DateTime date) {
    DateTime d = date ?? DateTime.now();
    return DateFormat('yyyy-MM-dd').format(d);
  }

  static compressImage(String path, int quality, {String targetPath}) async {
    String prePath = path.substring(0, path.lastIndexOf('/'));
    String imgName = path.substring(path.lastIndexOf("/") + 1, path.length);
    String suffix = imgName.substring(imgName.lastIndexOf(".") + 1, imgName.length);
    String tPath = targetPath ?? (prePath + '/$imgName' + '_composed.$suffix');
    var result = await FlutterImageCompress.compressAndGetFile(path, tPath, quality: quality);
    return result;
  }

  // static confirmPassword(
  //     {@required Function successCB,
  //     Function errorCB,
  //     BuildContext context}) async {
  //   String password = await Util.showPromptDialog(
  //     context: context,
  //     obscureText: true,
  //     title: tr('Confirm'),
  //     msg: tr('Enter your password'),
  //   );
  //   // if (ObjectUtil.isNotEmpty(password)) {
  //   // DioResponse passwordVerifyRes = await Util.dioRequest(
  //   //     url: ConsumerApis.verifyPassword, data: {'password': password});
  //   // if (passwordVerifyRes.isSuccess()) {
  //   //   successCB();
  //   // } else {
  //   //   if (errorCB != null) {
  //   //     errorCB();
  //   //   }
  //   // }
  //   // }
  // }

  static bool haveNewVersion(String newVersion, String old) {
    if (newVersion == null || newVersion.isEmpty || old == null || old.isEmpty) {
      return false;
    }
    int newVersionInt, oldVersion;
    var newList = newVersion.split('.');
    var oldList = old.split('.');
    if (newList.isEmpty || oldList.isEmpty) {
      return false;
    }
    for (int i = 0; i < newList.length; i++) {
      newVersionInt = int.parse(newList[i]);
      oldVersion = int.parse(oldList[i]);
      if (newVersionInt > oldVersion) {
        return true;
      } else if (newVersionInt < oldVersion) {
        return false;
      }
    }

    return false;
  }

  static String upperCaseFirst(String str) {
    if (str == null || str.isEmpty) {
      return '';
    }
    return str[0].toUpperCase() + str.substring(1);
  }
}
