// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:span_mobile/common/skux/skux_style.dart';

class SkuxAddWallet extends StatefulWidget {
  SkuxAddWallet({Key key, this.onClick}) : super(key: key);
  Function onClick;
  @override
  State<SkuxAddWallet> createState() => _SkuxAddWalletState();
}

class _SkuxAddWalletState extends State<SkuxAddWallet> {
  @override
  Widget build(BuildContext context) {
    return _walletArea();
  }

  Widget _walletArea() {
    return Semantics(
      // button: true,
      label: 'Add to ' + (Platform.isIOS ? 'Apple Wallet' : 'Google Wallet'),
      textField: true,
      explicitChildNodes: false,
      excludeSemantics: true,
      child: GestureDetector(
        child: Container(
          width: 140,
          height: 46,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: SkuxStyle.greyColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Semantics(
            button: true,
            explicitChildNodes: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/image/skux/wallet.svg',
                  width: 31,
                  height: 23,
                ),
                const SizedBox(
                  width: 5.5,
                ),
                Semantics(
                  explicitChildNodes: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                        child: Text(
                          tr('Add to'),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: Semantics(
                          child: Text(
                            Platform.isIOS ? 'Apple Wallet' : 'Google Wallet',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          if (widget.onClick != null) {
            widget.onClick();
          }
        },
      ),
    );
  }
}
