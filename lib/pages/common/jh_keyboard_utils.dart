///  jh_keyboard_utils.dart
///
///  Created by iotjin on 2020/04/10.
///  description:  Keyboard config

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class JhKeyboardUtils {
  static KeyboardActionsConfig getKeyboardConfig(
      BuildContext context, List<FocusNode> list) {
    return KeyboardActionsConfig(
//      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: List.generate(
          list.length,
          (i) => KeyboardActionsItem(
                focusNode: list[i],
                toolbarButtons: [
                  (node) {
                    return GestureDetector(
                        onTap: () => node.unfocus(),
                        child: Stack(
                            alignment: Alignment.centerRight,
                            children: <Widget>[
                              Container(
                                color: Colors.transparent,
                                width: 100,
                              ),
                              Positioned(
                                right: 15,
                                child: Text(tr('Close')),
                              ),
                            ]));
                  },
                ],
              )),
    );
  }
}
