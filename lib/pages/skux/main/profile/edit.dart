// ignore_for_file: non_constant_identifier_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/pages/common/jh_button.dart';
import 'package:span_mobile/pages/common/vlog.dart';
import 'package:span_mobile/pages/common/web_view.dart';
import 'package:span_mobile/pages/skux/common/api.dart';
import 'package:span_mobile/widgets/unfocus.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key key}) : super(key: key);
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  String _displayName;
  bool _canSubmitFullName;
  final double _headerIndex = 1;
  final double _nameIndex = 2;

  @override
  void initState() {
    _displayName = '';
    _canSubmitFullName = false;

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  final String GetCurrentUser = r'''
    query CurrentUser {
      currentUser {
        phoneNumber
        displayName
      }
    }
  ''';

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: gql(GetCurrentUser),
          onComplete: (data) {
            VLog(data);
            setState(() {
              _displayName = data['currentUser']['displayName'];
            });
            _nameController.text = _displayName;
          },
        ),
        builder: (result, {fetchMore, refetch}) {
          return SafeArea(
            child: SingleChildScrollView(
              child: UnFocusWidget(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Semantics(
                    explicitChildNodes: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _header(),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.only(top: 8),
                          child: Semantics(
                            explicitChildNodes: false,
                            excludeSemantics: true,
                            textField: true,
                            label: 'Full Name ' + _nameController.text + 'double tap to edit.',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  label: 'Name Edit',
                                  excludeSemantics: true,
                                  sortKey: OrdinalSortKey(_nameIndex),
                                  textField: true,
                                  child: Focus(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        hintText: 'Full Name',
                                        fillColor: Colors.white,
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      controller: _nameController,
                                      onChanged: (String fullName) {
                                        if (fullName != _displayName && fullName.isNotEmpty) {
                                          setState(() {
                                            _canSubmitFullName = true;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.0, child: Container()),
                                Mutation(
                                  options: MutationOptions(
                                    document: gql(r'''
                                        mutation UpdateUser($displayName: String!) {
                                          updateUser(displayName: $displayName) {
                                            displayName
                                          }
                                        }
                                      '''),
                                    onCompleted: (data) {
                                      setState(() {
                                        _nameController.text = data['updateUser']['displayName'];
                                        _canSubmitFullName = true;
                                      });
                                    },
                                  ),
                                  builder: (runMutation, result) {
                                    return JhButton(
                                      fontSize: 15,
                                      height: 50,
                                      text: 'Update your full name',
                                      weight: FontWeight.w600,
                                      onPressed: _canSubmitFullName == false
                                          ? null
                                          : () {
                                              setState(() {
                                                _canSubmitFullName = false;
                                              });
                                              runMutation({'displayName': _nameController.text});
                                            },
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 58,
                        ),
                        ExcludeSemantics(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              tr('Account Control'),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: SkuxStyle.textColor),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _settingItem('assets/image/skux/delete.svg', tr('Delete Account'), color: SkuxStyle.redColor, onTap: _deleteClicked),
                        const SizedBox(height: 200.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Semantics(
        explicitChildNodes: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 30,
            ),
            Semantics(
              child: Text(
                tr('Account'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: SkuxStyle.textColor,
                ),
              ),
              header: true,
              sortKey: OrdinalSortKey(_headerIndex),
            ),
            Semantics(
              child: IconButton(
                onPressed: _backButtonClicked,
                icon: SvgPicture.asset('assets/image/skux/close_gray.svg'),
              ),
              excludeSemantics: true,
              button: true,
              label: 'Close',
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingItem(String iconPath, String title, {Color color, double opacity = 1, Function onTap}) {
    return Semantics(
      button: true,
      label: title,
      sortKey: const OrdinalSortKey(4),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            child: Semantics(
              explicitChildNodes: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Semantics(
                    image: true,
                    child: SvgPicture.asset(
                      iconPath,
                      width: 24,
                      height: 24,
                      color: color ?? style.primaryColor,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Semantics(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color ?? style.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _deleteClicked() async {
    showCupertinoModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      expand: false,
      backgroundColor: SkuxStyle.bgColor,
      duration: const Duration(milliseconds: 300),
      builder: (context) => WebViewPage(
        url: SKUxAPI.deleteAccountWebUrl,
      ),
    );
  }

  _backButtonClicked() {
    Navigator.pop(context);
  }
}
