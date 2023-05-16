import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IosBtn extends StatefulWidget {
  @override
  _IosBtn createState() => _IosBtn();
}

class _IosBtn extends State<IosBtn> {
  static const platformChannel =
      MethodChannel('test.connect.methodchannel/iOS');

  String _iosText = 'IOS result';
  Future<void> _getStringIOS() async {
    String _result;
    try {
      final String result = await platformChannel.invokeMethod('checkTest');
      _result = result;
    } catch (e) {
      _result = "Can't fetch the method: '$e'.";
    }

    setState(() {
      _iosText = _result;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ElevatedButton(
          child: Text('Check IOS'),
          onPressed: _getStringIOS,
        ),
        Text(_iosText),
      ],
    ));
  }
}
