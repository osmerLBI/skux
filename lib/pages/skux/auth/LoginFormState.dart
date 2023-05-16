import 'package:flutter/foundation.dart';

class LoginFormState extends ChangeNotifier {
  String _phoneErrorMessageText = '';
  String _verificationCodeErrorMessageText = '';

  bool _canSubmitVerificationCode = false;

  void setCanSubmitVerificationCode(bool canSubmit) {
    _canSubmitVerificationCode = canSubmit;
    notifyListeners();
  }

  void setPhoneInputErrorMessage(String phoneErrorMessage) {
    _phoneErrorMessageText = phoneErrorMessage;
    notifyListeners();
  }

  bool phoneInputHasError() {
    return _phoneErrorMessageText.isNotEmpty;
  }

  void setVerificationCodeErrorMessage(String verificationCodeErrorMessage) {
    _verificationCodeErrorMessageText = verificationCodeErrorMessage;
    notifyListeners();
  }

  bool verificationCodeHasError() {
    return _verificationCodeErrorMessageText.isNotEmpty;
  }

  String get phoneErrorMessageText => _phoneErrorMessageText;
  String get verificationCodeErrorMessageText => _verificationCodeErrorMessageText;
  bool get canSubmitVerificationCode => _canSubmitVerificationCode;
}
