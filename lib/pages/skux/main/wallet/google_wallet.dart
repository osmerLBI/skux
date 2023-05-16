import 'package:flutter/material.dart';
import 'package:add_to_google_wallet/widgets/add_to_google_wallet_button.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/common/skux/skux_info.dart';
import 'package:span_mobile/common/pass/generic_class.dart';

class GoogleWallet extends StatefulWidget {
  const GoogleWallet({Key key, this.offer}) : super(key: key);
  final Map offer;

  @override
  _GoogleWallet createState() => _GoogleWallet();
}

class _GoogleWallet extends State<GoogleWallet> {
  @override
  void initState() {
    super.initState();
  }

  void _showSnackBar(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    print(
        "*******************************************************************");
    print(widget.offer['userCard']['accountNumber']);
    print(
        "*******************************************************************");
    Map offerItem = widget.offer['offer'];
    String description = offerItem['description'];
    String expiresAt = Util.formatTime(offerItem['expiresAt'],
        format: SkuxInfo.dateTimeFormat);
    String bannerUrl = offerItem['bannerUrl'];
    String offerUUID = offerItem['uuid'];
    GenericClass googleWallet = GenericClass(
        description, expiresAt, bannerUrl, offerUUID, widget.offer['userCard']);
    String getClass = googleWallet.getPass();
    return (Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AddToGoogleWalletButton(
          pass: getClass,
          onSuccess: () => _showSnackBar(context, 'Success!'),
          onCanceled: () => _showSnackBar(context, 'Action canceled.'),
          onError: (Object error) => _showSnackBar(context, error.toString()),
          locale: const Locale.fromSubtags(
            languageCode: 'en',
            countryCode: 'US',
          ),
        ),
      ],
    ));
  }
}
