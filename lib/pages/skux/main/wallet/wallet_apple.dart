import 'package:flutter/material.dart';
import 'package:span_mobile/common/pass/pass_provider.dart';
import 'package:add_to_wallet/add_to_wallet.dart';
import 'package:span_mobile/pages/skux/main/wallet/google_wallet.dart';

class AppleWallet extends StatefulWidget {
  const AppleWallet({Key key, this.offer}) : super(key: key);
  final Map offer;

  @override
  _AppleWallet createState() => _AppleWallet();
}

class _AppleWallet extends State<AppleWallet> {
  bool _passLoaded = false;
  List<int> _pkPassData = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    final pass = await passProvider();

    if (!mounted) return;

    setState(() {
      _pkPassData = pass;
      _passLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Column(children: [
          _passLoaded
              ? AddToWalletButton(
                  pkPass: _pkPassData,
                  width: 150,
                  height: 100,
                  unsupportedPlatformChild: GoogleWallet(offer: widget.offer),
                  onPressed: () {
                    print("🎊Add to Wallet button Pressed!🎊");
                  },
                )
              : CircularProgressIndicator()
        ]),
      ],
    ));
  }
}
