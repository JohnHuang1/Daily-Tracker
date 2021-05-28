import 'package:daily_tracker/screens/viewnotifiers/startup_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider_architecture/_viewmodel_provider.dart';

class StartUpScreen extends StatelessWidget {
  const StartUpScreen({Key key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<StartUpNotifier>.withConsumer(
      viewModelBuilder: () => StartUpNotifier(),
      onModelReady: (model) => model.handleStartUpLogic(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Daily Tracker',
              style: TextStyle(
                fontSize: 40,
              )),
              CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Color(0xff197cc1)),)
            ],
          )
        )
      )
    );
  }
}