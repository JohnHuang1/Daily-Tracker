import 'package:daily_tracker/locator.dart';
import 'package:daily_tracker/screens/counters/calendar_screen.dart';
import 'package:daily_tracker/screens/counters/counter_screen.dart';
import 'package:daily_tracker/screens/login/login_screen.dart';
import 'package:daily_tracker/screens/login/signup_screen.dart';
import 'package:daily_tracker/screens/startup_screen.dart';
import 'package:daily_tracker/shared/shared_styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:daily_tracker/services/dialog_service.dart';
import 'package:daily_tracker/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'const/routes.dart';
import 'managers/dialog_manager.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // debugPaintSizeEnabled = true;
    return MaterialApp(
      title: 'Daily Tracker',
      theme: _theme(),
      home: StartUpScreen(),
      onGenerateRoute: _routeFactory,
      navigatorKey: locator<NavigationService>().navigationKey,
      builder: (context, child) => Navigator(
        key: locator<DialogService>().dialogNavigationKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => DialogManager(child: child)),
      ),
    );
  }

  Route<dynamic> _routeFactory(RouteSettings settings){
      switch(settings.name) {
        case LoginViewRoute:
          return _getPageRoute(
            routeName: settings.name,
            viewToShow: LoginScreen(),
          );
        case SignUpViewRoute:
          return _getPageRoute(
            routeName: settings.name,
            viewToShow: SignUpScreen(),
          );
        case CounterViewRoute:
          return _getPageRoute(
            routeName: settings.name,
            viewToShow: CounterScreen(startIndex: settings.arguments as int),
          );
        case CalendarViewRoute:
          return _getPageRoute(
            routeName: settings.name,
            viewToShow: CalendarScreen(startIndex: settings.arguments as int),
          );
        default:
          return MaterialPageRoute(
              builder: (_) =>
                  Scaffold(
                      body: Center(
                        child: Text('No route defined for ${settings.name}'),
                      )
                  )
          );
      }
    }

  PageRoute _getPageRoute({String routeName, Widget viewToShow}) {
    return MaterialPageRoute(
        settings: RouteSettings(
          name: routeName,
        ),
        builder: (_) => viewToShow);
  }

  ThemeData _theme(){
    return ThemeData(
      primaryColor: LawnGreen,
      backgroundColor: Color.fromARGB(255, 26, 27, 30),
      appBarTheme: AppBarTheme(
        textTheme: TextTheme(headline6: AppBarTextStyle),
      ),
      textTheme: TextTheme(
        headline6: TitleTextStyle,
        bodyText2: BodyText2TextStyle,
        subtitle2: Subtitle2TextStyle,
      )
    );
  }
}

