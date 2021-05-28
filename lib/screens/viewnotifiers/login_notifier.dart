import 'package:daily_tracker/const/routes.dart';
import 'package:daily_tracker/main.dart';
import 'package:daily_tracker/services/dialog_service.dart';
import 'package:daily_tracker/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:daily_tracker/screens/viewnotifiers/base_notifier.dart';
import 'package:daily_tracker/services/authentication_service.dart';
import 'package:flutter/foundation.dart';

import '../../locator.dart';

class LoginNotifier extends BaseNotifier{
  final AuthenticationService _authenticationService = locator<AuthenticationService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  Future login({@required String email, @required String password,}) async {
    setBusy(true);

    
    var result = await _authenticationService.loginWithEmail(email: email, password: password);

    setBusy(false);

    if(result is bool) {
      if(result){
        _navigationService.navigateReplaceTo(CounterViewRoute);
      } else {
        await _dialogService.showDialog(
          title: 'Login Failure',
          description: 'General login failure. Please try again later',
        );
      }
    } else {
      await _dialogService.showDialog(
        title: 'Sign Up Failure',
        description: result,
      );
    }
  }

  void navigateToSignUp() {
    _navigationService.navigateTo(SignUpViewRoute);
  }

}