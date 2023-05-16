import 'package:common_utils/common_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/pages/common/jh_button.dart';
import 'package:span_mobile/widgets/unfocus.dart';

class FullNamePage extends StatefulWidget {
  const FullNamePage({Key key}) : super(key: key);

  @override
  State<FullNamePage> createState() => _FullNamePageState();
}

class _FullNamePageState extends State<FullNamePage> {
  final TextEditingController _fullNameController = TextEditingController();
  final FocusNode _fullNameFocusNode = FocusNode();
  bool _canClick = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fullNameFocusNode.unfocus();
    _fullNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkuxStyle.bgColor,
      body: OrientationBuilder(builder: (context, orientation) {
        return SafeArea(
          child: Semantics(
            // label: 'Enter You Full Name Page',
            explicitChildNodes: true,
            child: SingleChildScrollView(
              child: UnFocusWidget(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Semantics(
                    // label: 'Enter You Full Name Page',
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _top(),
                        const SizedBox(
                          height: 16,
                        ),
                        Semantics(
                          child: Text(
                            tr('Enter your full name'),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: SkuxStyle.textColor),
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Semantics(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: tr('Full Name'),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 16),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              controller: _fullNameController,
                              focusNode: _fullNameFocusNode,
                              onChanged: (value) {
                                String name = _fullNameController.text;
                                bool isClick = true;
                                if (ObjectUtil.isEmpty(name)) {
                                  isClick = false;
                                }
                                if (isClick != _canClick) {
                                  setState(() {
                                    _canClick = isClick;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 42,
                        ),
                        Semantics(
                          child: JhButton(
                              onPressed: _canClick == false
                                  ? null
                                  : _continueButtonClicked,
                              borderRadius: BorderRadius.circular(8),
                              width: 182,
                              height: 40,
                              text: tr('Continue'),
                              fontSize: 15,
                              weight: FontWeight.w600,
                              textColor: Colors.white,
                              color: style.primaryColor),
                        ),
                      ],
                    ),
                    explicitChildNodes: true,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _top() {
    return Semantics(
      explicitChildNodes: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 30,
          ),
          Semantics(
            image: true,
            child: ExtendedImage.asset(
              'assets/image/skux/man.png',
              width: 160,
              height: 160,
            ),
          ),
          Semantics(
            label: 'Close',
            child: IconButton(
              onPressed: _backButtonClicked,
              icon: SvgPicture.asset('assets/image/skux/close_gray.svg'),
            ),
          ),
        ],
      ),
    );
  }

  void _continueButtonClicked() async {}

  // void _continueButtonClicked() async {
  //   if (_fullNameController.text.isEmpty ||
  //       _fullNameController.text == kDefaultUserName) {
  //     return;
  //   }
  //   DioResponse resp =
  //       await Util.dioRequest(url: SKUxAPI.profileUrl, method: 'POST', data: {
  //     'name': _fullNameController.text,
  //   });
  //   if (resp.isSuccess()) {
  //     userStore.refreshUser(loading: true);
  //     Navigator.pop(context);
  //   }
  // }

  void _backButtonClicked() {
    Navigator.pop(context);
  }
}
