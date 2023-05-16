import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/widgets/unfocus.dart';

class SocialLoginPage extends StatefulWidget {
  const SocialLoginPage({Key key}) : super(key: key);

  @override
  State<SocialLoginPage> createState() => _SocialLoginPageState();
}

class _SocialLoginPageState extends State<SocialLoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkuxStyle.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: UnFocusWidget(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon:
                          SvgPicture.asset('assets/image/skux/close_gray.svg'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ExtendedImage.asset('assets/image/skux/man.png'),
                  const SizedBox(height: 40),
                  _socialButton(
                    'assets/image/skux/google.svg',
                    tr('Sign in with Google'),
                    const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF757575),
                    ),
                    Colors.white,
                    onClick: _googleLoginClicked,
                  ),
                  const SizedBox(height: 24),
                  _socialButton(
                    'assets/image/skux/apple.svg',
                    tr('Sign in with Apple'),
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    Colors.black,
                    onClick: _appleLoginClicked,
                  ),
                  const SizedBox(height: 24),
                  _socialButton(
                    'assets/image/skux/fb.svg',
                    tr('Continue with Facebook'),
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    const Color(0xFF1877F2),
                    onClick: _facebookLoginClicked,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(
      String iconPath, String title, TextStyle ts, Color bgColor,
      {Function onClick}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
        ),
        onPressed: () {
          if (onClick != null) {
            onClick();
          }
        },
        icon: SvgPicture.asset(iconPath),
        label: Text(
          title,
          style: ts,
        ),
      ),
    );
  }

  void _appleLoginClicked() {}
  void _googleLoginClicked() {}
  void _facebookLoginClicked() {}
}
