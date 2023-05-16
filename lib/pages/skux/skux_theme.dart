import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/common/util.dart';

class SkuxTheme extends StatefulWidget {
  final Widget child;

  const SkuxTheme({Key key, this.child}) : super(key: key);

  @override
  State<SkuxTheme> createState() => _SkuxThemeState();
}

class _SkuxThemeState extends State<SkuxTheme> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(
        color: SkuxStyle.borderColor,
      ),
    );

    ThemeData old = Theme.of(context);
    // TextTheme oldText = GoogleFonts.poppinsTextTheme(old.textTheme);
    TextTheme oldText = old.textTheme;
    ThemeData newTd = ThemeData(
      fontFamily: 'EuclidCircularA',
      primaryColor: style.primaryColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: old.appBarTheme.copyWith(
        color: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontFamily: style.fontFamily5,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: old.inputDecorationTheme.copyWith(
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(
            color: style.primaryColor,
          ),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(
            color: style.errorColor,
          ),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(
            color: style.errorColor,
          ),
        ),
        disabledBorder: border,
        labelStyle:
            const TextStyle(fontFamily: 'EuclidCircularA', fontSize: 15),
        contentPadding: const EdgeInsets.all(15),
      ),
      textTheme: oldText.copyWith(
        titleMedium: oldText.titleMedium.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        titleSmall: oldText.titleSmall.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        bodyLarge: oldText.bodyLarge.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        bodyMedium: oldText.bodyMedium.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        displayLarge: oldText.displayLarge.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        displayMedium: oldText.displayMedium.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        displaySmall: oldText.displaySmall.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        headlineMedium: oldText.headlineMedium.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        headlineSmall: oldText.headlineSmall.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        titleLarge: oldText.titleLarge.copyWith(
            color: SkuxStyle.textColor, fontFamily: 'EuclidCircularA'),
        labelLarge: oldText.labelLarge
            .copyWith(fontSize: 16, fontFamily: 'EuclidCircularA'),
        bodySmall: oldText.bodySmall.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: style.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: Util.radius(12)),
          textStyle:
              const TextStyle(fontFamily: 'EuclidCircularA', fontSize: 16),
          minimumSize: const Size(30, 20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: style.primaryColor,
          textStyle:
              const TextStyle(fontFamily: 'EuclidCircularA', fontSize: 16),
          minimumSize: const Size(30, 20),
        ),
      ),
      primaryTextTheme: old.primaryTextTheme.copyWith(
        titleMedium: oldText.titleMedium.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        titleSmall: oldText.titleSmall.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        bodyLarge: oldText.bodyLarge.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        bodyMedium: oldText.bodyMedium.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        displayLarge: oldText.displayLarge.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        displayMedium: oldText.displayMedium.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        displaySmall: oldText.displaySmall.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        headlineMedium: oldText.headlineMedium.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        headlineSmall: oldText.headlineSmall.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
        titleLarge: oldText.titleLarge.copyWith(
            color: SkuxStyle.textColor, fontFamily: 'EuclidCircularA'),
        labelLarge: oldText.labelLarge
            .copyWith(fontSize: 16, fontFamily: 'EuclidCircularA'),
        bodySmall: oldText.bodySmall.copyWith(
          fontFamily: 'EuclidCircularA',
        ),
      ),
      colorScheme:
          ColorScheme.fromSwatch(primarySwatch: SkuxStyle.kPrimaryColor)
              .copyWith(error: style.errorColor)
              .copyWith(background: Colors.white),
    );
    return Theme(
      child: widget.child,
      data: newTd,
    );
  }
}
