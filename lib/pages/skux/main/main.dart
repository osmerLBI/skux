import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/pages/common/const.dart';
import 'package:span_mobile/pages/skux/auth/AuthenticationState.dart';
import 'package:span_mobile/pages/skux/main/wallet/index.dart';
import 'package:span_mobile/pages/skux/main/profile/index.dart';
import 'package:span_mobile/states/event_hub_state.dart';
import 'package:span_mobile/pages/skux/main/wallet/ios_btn.dart';

import 'offer/index.dart';

class SkuxMainPage extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const SkuxMainPage({Key key, @required this.navigatorKey}) : super(key: key);

  @override
  _SkuxMainPageState createState() => _SkuxMainPageState();
}

class _SkuxMainPageState extends EventHubState<SkuxMainPage> {
  int _currentIndex;
  Color selColor = style.primaryColor;
  String _uuid;
  List<Widget> pages;

  @override
  void initState() {
    bindEvent(kOpenCardEvent, (data) {
      setState(() {
        _currentIndex = 0;
        if (data['uuid'] != null) {
          _uuid = data['uuid'];
        }
      });
    });
    bindEvent(kShowOpenPageEvent, (_) {
      setState(() {
        _currentIndex = 2;
      });
    });
    _currentIndex = 2;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationState>(
      builder: (context, AuthenticationState authState, child) {
        return AnnotatedRegion(
          child: Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: SkuxStyle.bgColor,
            appBar: PreferredSize(
              child: Platform.isAndroid
                  ? Container()
                  : AppBar(
                      backgroundColor: SkuxStyle.bgColor,
                      elevation: 0,
                    ),
              preferredSize: const Size.fromHeight(0),
            ),
            body: IndexedStack(
              index: _currentIndex,
              sizing: StackFit.expand,
              children: [
                WalletPage(uuid: _uuid),
                SkuxProfilePage(navigatorKey: widget.navigatorKey),
                const OfferPage(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
                backgroundColor: SkuxStyle.bgColor,
                currentIndex: _currentIndex,
                onTap: _onTabClicked,
                items: [
                  BottomNavigationBarItem(
                    label: 'Home',
                    icon: Semantics(
                      label: 'Home Page',
                      excludeSemantics: true,
                      image: false,
                      button: true,
                      child: SvgPicture.asset(
                        'assets/image/skux/home_normal.svg',
                        width: 24.0,
                        height: 24.0,
                      ),
                    ),
                    activeIcon: Semantics(
                      excludeSemantics: true,
                      label: 'Home Page',
                      image: false,
                      button: true,
                      child: SvgPicture.asset(
                        'assets/image/skux/home_selected.svg',
                        width: 24.0,
                        height: 24.0,
                      ),
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: 'Profile',
                    icon: Semantics(
                      label: 'Profile Page',
                      excludeSemantics: true,
                      image: false,
                      button: true,
                      child: SvgPicture.asset(
                        'assets/image/skux/profile_normal.svg',
                        width: 24.0,
                        height: 24.0,
                      ),
                    ),
                    activeIcon: Semantics(
                      excludeSemantics: true,
                      label: 'Profile Page',
                      image: false,
                      button: true,
                      child: SvgPicture.asset(
                        'assets/image/skux/profile_selected.svg',
                        width: 24.0,
                        height: 24.0,
                      ),
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: 'Offers',
                    icon: Semantics(
                      child: SvgPicture.asset(
                        'assets/image/skux/offer_normal.svg',
                        width: 24.0,
                        height: 24.0,
                      ),
                      label: 'Offer Page',
                      image: false,
                      button: true,
                      excludeSemantics: true,
                    ),
                    activeIcon: Semantics(
                      child: SvgPicture.asset(
                        'assets/image/skux/offer_selected.svg',
                        width: 24.0,
                        height: 24.0,
                      ),
                      label: 'Offer Page',
                      image: false,
                      button: true,
                      excludeSemantics: true,
                    ),
                  ),
                ]),
          ),
          value: const SystemUiOverlayStyle(
            statusBarColor: SkuxStyle.bgColor,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: SkuxStyle.bgColor,
          ),
        );
      },
    );
  }

  void _onTabClicked(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
