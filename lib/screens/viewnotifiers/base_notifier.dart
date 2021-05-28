import 'package:daily_tracker/models/user.dart';
import 'package:daily_tracker/services/authentication_service.dart';
import 'package:flutter/cupertino.dart';

import '../../locator.dart';

class BaseNotifier extends ChangeNotifier{

  final AuthenticationService _authenticationService = locator<AuthenticationService>();

  User get currentUser => _authenticationService.currentUser;

  bool _busy = false;
  bool get busy => _busy;
  void setBusy(bool value) {

    _busy = value;
    notifyListeners();
  }
}