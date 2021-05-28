import 'package:daily_tracker/const/routes.dart';
import 'package:daily_tracker/main.dart';
import 'package:daily_tracker/services/dialog_service.dart';
import 'package:daily_tracker/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:daily_tracker/screens/viewnotifiers/base_notifier.dart';
import 'package:daily_tracker/services/authentication_service.dart';
import 'package:flutter/foundation.dart';

import '../../locator.dart';

class SignUpNotifier extends BaseNotifier {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  String _selectedRole = 'Select a User Role';

  String get selectedRole => _selectedRole;

  void setSelectedRole(dynamic role) {
    _selectedRole = role;
    notifyListeners();
  }

  Future signUp(
      {@required String email,
      @required String password,
      @required String fullName,}) async {
    setBusy(true);

    var result = await _authenticationService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        userRole: _selectedRole);

    setBusy(false);

    if (result is bool) {
      if (result) {
        _navigationService.navigateReplaceTo(CounterViewRoute);
      } else {
        await _dialogService.showDialog(
          title: 'Sign Up Failure',
          description: 'General sign up failure. Please try again later',
        );
      }
    } else {
      await _dialogService.showDialog(
        title: 'Sign Up Failure',
        description: result,
      );
    }
  }

  void navigateToLogin() {
    _navigationService.navigateTo(LoginViewRoute);
  }
}
