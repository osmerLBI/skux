import 'package:common_utils/common_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:span_mobile/common/skux/skux_info.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/pages/skux/auth/AuthenticationState.dart';
import 'package:span_mobile/pages/skux/main/profile/edit.dart';
import 'package:span_mobile/store/skux_user_store.dart';
import 'package:span_mobile/widgets/unfocus.dart';

class SkuxProfilePage extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const SkuxProfilePage({Key key, @required this.navigatorKey}) : super(key: key);

  @override
  _SkuxProfilePageState createState() => _SkuxProfilePageState();
}

class _SkuxProfilePageState extends State<SkuxProfilePage> {
  double _headerIndex = 1;
  double _editIndex = 2;
  double _signoutIndex = 3;
  @override
  void initState() {
    super.initState();
  }

  logout(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    BuildContext routeContext = context;
    return Scaffold(
      backgroundColor: SkuxStyle.bgColor,
      body: SafeArea(
        child: OrientationBuilder(
          builder: ((context, orientation) {
            return SingleChildScrollView(
              child: UnFocusWidget(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  height: MediaQuery.of(context).size.height - 100,
                  child: Semantics(
                    // label: 'Profile Page',
                    explicitChildNodes: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Semantics(
                            explicitChildNodes: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // _header(),
                                const SizedBox(
                                  height: 30,
                                ),
                                _avatarLine(),
                                const SizedBox(
                                  height: 40,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Semantics(
                                    header: true,
                                    sortKey: OrdinalSortKey(_headerIndex),
                                    child: Text(
                                      tr('Settings'),
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: SkuxStyle.textColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                  child: Consumer<AuthenticationState>(
                                    builder: (BuildContext context, AuthenticationState authState, Widget widget) {
                                      AuthenticationState _authState = authState;
                                      return Semantics(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Semantics(
                                              sortKey: OrdinalSortKey(_editIndex),
                                              explicitChildNodes: false,
                                              excludeSemantics: true,
                                              button: true,
                                              label: 'Edit Profile',
                                              child: InkWell(
                                                onTap: _editItemClicked,
                                                child: Opacity(
                                                  opacity: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                                    child: Semantics(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Semantics(
                                                            image: true,
                                                            label: 'Icon',
                                                            child: SvgPicture.asset(
                                                              'assets/image/skux/edit.svg',
                                                              width: 24,
                                                              height: 24,
                                                              color: style.primaryColor,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Semantics(
                                                            child: Text(
                                                              'Edit Profile',
                                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: style.primaryColor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      explicitChildNodes: true,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Semantics(
                                              sortKey: OrdinalSortKey(_signoutIndex),
                                              explicitChildNodes: false,
                                              excludeSemantics: true,
                                              button: true,
                                              label: 'Sign Out',
                                              child: InkWell(
                                                onTap: () {
                                                  onPress() async {
                                                    await SkuxInfo.clearRecentViewed();
                                                    await _authState.didUnauthenticate();
                                                    logout(routeContext);
                                                  }

                                                  showDialog<void>(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext dialogContext) {
                                                      return AlertDialog(
                                                        title: Semantics(
                                                          label: 'Sign out',
                                                          excludeSemantics: true,
                                                          header: true,
                                                          child: const Text('Sign out confirmation.'),
                                                        ),
                                                        content: Text(tr('Are you sure you would like to sign out?')),
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
                                                              Navigator.pop(dialogContext);
                                                              setState(() {
                                                                _editIndex = 3;
                                                                _headerIndex = 2;
                                                                _signoutIndex = 1;
                                                              });
                                                            },
                                                          ),
                                                          ElevatedButton(
                                                            child: const Text('Ok'),
                                                            style: ElevatedButton.styleFrom(
                                                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                                                              backgroundColor: const Color(0xFF0674DB),
                                                            ),
                                                            onPressed: onPress,
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Opacity(
                                                  opacity: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                                    child: Semantics(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Semantics(
                                                            image: true,
                                                            label: 'Icon',
                                                            child: SvgPicture.asset(
                                                              'assets/image/skux/logout.svg',
                                                              width: 24,
                                                              height: 24,
                                                              color: style.primaryColor,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Semantics(
                                                            child: Text(
                                                              'Sign Out',
                                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: style.primaryColor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      explicitChildNodes: true,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        explicitChildNodes: true,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Semantics(
                          label: 'Version ',
                          child: Text(
                            Util.getVersion(),
                            style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _avatarLine() {
    return Semantics(
      explicitChildNodes: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 24,
          ),
          Expanded(
            child: Semantics(
              explicitChildNodes: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tooltip(
                    message: userStore.user.displayName ?? '',
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 16 - 16 - 80 - 24,
                      child: ObjectUtil.isEmpty(userStore.user.displayName)
                          ? Container()
                          : Semantics(
                              excludeSemantics: true,
                              explicitChildNodes: false,
                              child: Text(
                                userStore.user.displayName ?? '',
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: SkuxStyle.textColor),
                              ),
                              label: 'First Name',
                            ),
                    ),
                  ),
                  Tooltip(
                    message: userStore.user.displayName ?? '',
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 16 - 16 - 80 - 24,
                      child: ObjectUtil.isEmpty(userStore.user.displayName)
                          ? Container()
                          : Semantics(
                              excludeSemantics: true,
                              explicitChildNodes: false,
                              child: Text(
                                userStore.user.displayName ?? '',
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: SkuxStyle.textColor),
                              ),
                              label: 'Last Name',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editItemClicked() {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      isDismissible: false,
      backgroundColor: SkuxStyle.bgColor,
      duration: const Duration(milliseconds: 300),
      builder: (context) => const EditProfilePage(),
    ).then((value) {
      setState(() {
        _editIndex = 1;
        _headerIndex = 2;
        _signoutIndex = 3;
      });
    });
  }
}
