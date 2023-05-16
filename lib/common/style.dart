import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:span_mobile/common/platform.dart';
import 'package:span_mobile/common/skux/skux_style.dart';

Style style;

class Style {
  Color primaryColor = Colors.blue;
  Color successColor = Colors.green;
  Color lightSuccessColor = Colors.green[50];
  Color errorColor = Colors.red;
  Color lightErrorColor = Colors.red[50];
  Color warningColor = Colors.amber;
  Color lightWarningColor = Colors.amber[50];
  Color snackBarColor = Colors.black87;
  Color blueColor = Colors.blue;
  Color lightBlueColor = Colors.blue[50];
  Color psdEyeIconColor = const Color(0xFFCCCCCC);
  Color lightPrimaryColor = const Color(0x7f2196F3);

  static const Color bgColor = Color.fromRGBO(238, 238, 238, 1);

  Widget logoWidget = Container();
  Widget darkLogoWidget = Container();

  String fontFamily1;
  String fontFamily2;
  String fontFamily3;
  String fontFamily4;
  String fontFamily5;
  String fontFamily6;
  String fontFamily7;
  String fontFamily8;
  String fontFamily9;

  String monoFontFamily1;
  String monoFontFamily2;
  String monoFontFamily3;
  String monoFontFamily4;
  String monoFontFamily5;
  String monoFontFamily6;
  String monoFontFamily7;
  String monoFontFamily8;
  String monoFontFamily9;

  static void init() {
    LicenseRegistry.addLicense(() async* {
      final license = await rootBundle.loadString('google_fonts/OFL.txt');
      yield LicenseEntryWithLineBreaks(['google_fonts'], license);
    });

    resetStyle();
  }

  static void resetStyle() {
    if (Platform.SKUX) {
      style = SkuxStyle();
    } else {
      style = Style();
    }
  }

  Style() {
    fontFamily1 = fontFamily(FontWeight.w100);
    fontFamily2 = fontFamily(FontWeight.w200);
    fontFamily3 = fontFamily(FontWeight.w300);
    fontFamily4 = fontFamily(FontWeight.w400);
    fontFamily5 = fontFamily(FontWeight.w500);
    fontFamily6 = fontFamily(FontWeight.w600);
    fontFamily7 = fontFamily(FontWeight.w700);
    fontFamily8 = fontFamily(FontWeight.w800);
    fontFamily9 = fontFamily(FontWeight.w900);

    monoFontFamily1 = monoFontFamily(FontWeight.w100);
    monoFontFamily2 = monoFontFamily(FontWeight.w200);
    monoFontFamily3 = monoFontFamily(FontWeight.w300);
    monoFontFamily4 = monoFontFamily(FontWeight.w400);
    monoFontFamily5 = monoFontFamily(FontWeight.w500);
    monoFontFamily6 = monoFontFamily(FontWeight.w600);
    monoFontFamily7 = monoFontFamily(FontWeight.w700);
    monoFontFamily8 = monoFontFamily(FontWeight.w800);
    monoFontFamily9 = monoFontFamily(FontWeight.w900);

    initLogoWidget();
  }

  void initLogoWidget() {
    logoWidget = const CircleAvatar(
      radius: 36,
      backgroundColor: Colors.white,
    );
    darkLogoWidget = CircleAvatar(
      radius: 36,
      backgroundColor: Colors.grey[600],
    );
  }

  String fontFamily(FontWeight fontWeight) {
    return TextStyle(
      fontWeight: fontWeight,
    ).fontFamily;
  }

  String monoFontFamily(FontWeight fontWeight) {
    return GoogleFonts.robotoMono(
      fontWeight: fontWeight,
    ).fontFamily;
  }
}
