import 'dart:io';
import 'package:flutter/material.dart';
import 'package:span_mobile/common/pass/pass_provider.dart';
import 'package:add_to_wallet/add_to_wallet.dart';
import 'package:span_mobile/pages/skux/main/wallet/google_wallet.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/common/skux/skux_info.dart';

class AppleWalletDynamic extends StatefulWidget {
  const AppleWalletDynamic({Key key, this.offer}) : super(key: key);
  final Map offer;

  @override
  _AppleWalletDynamic createState() => _AppleWalletDynamic();
}

class _AppleWalletDynamic extends State<AppleWalletDynamic> {
  bool _passLoaded = false;
  List<int> _pkPassData = [];

  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

  Future<void> initPlatformState() async {
    Map offerItem = widget.offer['offer'];
    String description = offerItem['description'];
    String expiresAt = Util.formatTime(offerItem['expiresAt'],
        format: SkuxInfo.dateTimeFormat);
    String offerUUID = offerItem['uuid'];

    final pass = await passProviderDynamic(description, expiresAt, offerUUID,
        widget.offer['userCard']['accountNumber']);

    if (!mounted) return;

    setState(() {
      _pkPassData = pass;
      _passLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      initPlatformState();
    } else {
      setState(() {
        _passLoaded = true;
      });
    }

    return (Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  color: Colors.white,
                  child: Center(
                    child: _passLoaded
                        ? AddToWalletButton(
                            pkPass: _pkPassData,
                            width: 150,
                            height: 30,
                            unsupportedPlatformChild:
                                GoogleWallet(offer: widget.offer),
                            onPressed: () {
                              print("🎊Add to Wallet button Pressed!🎊");
                            },
                          )
                        : Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Loading Pass ....'),
                              Container(height: 16),
                              CircularProgressIndicator()
                            ],
                          )),
                  ),
                ),
              ),
            ]),
      ],
    ));
  }
}
