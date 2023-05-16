// ignore_for_file: overridden_fields

import 'package:flutter/material.dart';
import 'package:span_mobile/common/style.dart';

class SkuxStyle extends Style {
  // Color primaryColor = const Color(0xFF0078E0);
  // Color primaryColor = const Color(0xFF0674DB);
  @override
  Color primaryColor = const Color(0XFF036FD3);
  @override
  Color successColor = const Color(0xFF33C759);
  @override
  Color lightSuccessColor = const Color.fromRGBO(224, 250, 230, 1);
  @override
  Color errorColor = const Color(0xFFDF0C01);
  @override
  Color lightErrorColor = const Color.fromRGBO(255, 233, 239, 1);
  @override
  Color warningColor = const Color.fromRGBO(253, 195, 65, 1);
  @override
  Color lightWarningColor = const Color.fromRGBO(255, 183, 42, 0.12);
  @override
  Color snackBarColor = const Color(0xFF5856D6);
  @override
  Color blueColor = const Color.fromRGBO(0, 98, 255, 1);
  @override
  Color lightBlueColor = const Color.fromRGBO(0, 145, 214, 0.3);
  @override
  Color psdEyeIconColor = const Color(0xFFCCCCCC);
  @override
  Color lightPrimaryColor = const Color(0x8C5856D6);

  static const Color scanVerifyFailedColor = Color(0xFFE86062);

  static const Color bgColor = Color(0xFFF5F6FD);
  // static const Color bgColor = const Color(0xFF696E91);

  static const Color darkColor = Color.fromRGBO(23, 23, 37, 1);
  static const Color greyColor = Color.fromRGBO(37, 41, 64, 1);
  static const Color lightColor = Color.fromRGBO(146, 146, 157, 1);
  static const Color inactiveColor = Color.fromRGBO(213, 213, 214, 1);
  static const Color inactiveWithLightGreyColor = Color(0xFF666B85);
  static const Color borderColor = Color(0xFFCCCCCC);
  static const Color readonlyColor = Color.fromRGBO(245, 245, 245, 1);
  static const Color textColor = Color(0xFF232A51);
  static const Color text64Color = Color(0xA4232A51);
  static const Color text80Color = Color(0xCC232A51);
  static const Color lightGreyColor = Color(0xFF8E8E93);
  static const Color disabledColor = Color(0xFFA5A6F6);
  static const Color greenColor = Color(0xFF13813A);
  static const Color redColor = Color(0xFFE00034);
  static const Color contrast3xWhiteColor = Color(0xFF94949F);
  static const Color contrast45xWhiteColor = Color(0xFF777770);
  static const Color contrast461WhiteColor = Color.fromARGB(255, 1, 1, 1);
  // static const Color contrastGreyColor = const Color(0xFF69708C);
  static const Color contrastGreyColor = Color(0xFF696E91);

  static const MaterialColor kPrimaryColor = MaterialColor(
    0xFF5856D6,
    // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      900: Color(0xE55856D6), //10%
      800: Color(0xCC5856D6), //20%
      700: Color(0xB25856D6), //30%
      600: Color(0x995856D6), //40%
      500: Color(0x7F5856D6), //50%
      400: Color(0x665856D6), //60%
      300: Color(0x4c5856D6), //70%
      200: Color(0x335856D6), //80%
      100: Color(0x195856D6), //90%
      50: Color(0xFF5856D6), //100%
    },
  );

  @override
  void initLogoWidget() {
    logoWidget = Image.asset('assets/image/spendr/spendr_logo.svg');
    darkLogoWidget = Image.asset('assets/image/spendr/spendr_logo.svg');
  }

  @override
  String fontFamily(FontWeight fontWeight) {
    return TextStyle(fontWeight: fontWeight, fontFamily: 'EuclidCircularA')
        .fontFamily;
  }

  @override
  String monoFontFamily(FontWeight fontWeight) {
    return TextStyle(fontWeight: fontWeight, fontFamily: 'EuclidCircularA')
        .fontFamily;
  }
}
