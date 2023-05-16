// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationState extends ChangeNotifier {
  String _authenticationToken;
  String _refreshToken;
  bool _isAuthenticated = false;
  int _expirationTimestamp;

  Future<void> didAuthenticate(token, refreshToken, expirationTimestamp, {Object userInfo}) async {
    int timestamp;
    if (expirationTimestamp is String) {
      timestamp = int.tryParse(expirationTimestamp);
    } else {
      timestamp = expirationTimestamp;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('authenticationToken', token);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setInt('expirationTimestamp', timestamp);

    _isAuthenticated = true;
    _authenticationToken = token;
    _refreshToken = refreshToken;
    _expirationTimestamp = timestamp;

    notifyListeners();
  }

  Future<void> didUnauthenticate() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('authenticationToken');
    await prefs.remove('refreshToken');
    await prefs.remove('expirationTimestamp');

    _isAuthenticated = false;
    _authenticationToken = null;
    _refreshToken = null;
    _expirationTimestamp = null;

    notifyListeners();
  }

  bool isTokenExpired() {
    return _expirationTimestamp > DateTime.now().millisecondsSinceEpoch;
  }

  String get authenticationToken => _authenticationToken;
  String get refreshToken => _refreshToken;
  bool get isAuthenticated => _isAuthenticated;
  int get expirationTimestamp => _expirationTimestamp;
}
