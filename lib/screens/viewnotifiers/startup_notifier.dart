import 'package:daily_tracker/const/routes.dart';
import 'package:daily_tracker/services/authentication_service.dart';
import 'package:daily_tracker/services/navigation_service.dart';
import 'package:daily_tracker/locator.dart';

import 'base_notifier.dart';

class StartUpNotifier extends BaseNotifier {
  final AuthenticationService _authenticationService = locator<AuthenticationService>();
  final NavigationService _navigationService = locator<NavigationService>();

  Future handleStartUpLogic() async {
    var hasLoggedInUser = await _authenticationService.isUserLoggedIn();

    if(hasLoggedInUser) {
      _navigationService.navigateReplaceTo(CounterViewRoute);
    } else {
      _navigationService.navigateReplaceTo(LoginViewRoute);
    }
  }
}