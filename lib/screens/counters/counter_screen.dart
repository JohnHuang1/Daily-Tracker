import 'package:daily_tracker/models/streak.dart';
import 'package:daily_tracker/screens/counters/widgets/busy_checkbox.dart';
import 'package:daily_tracker/screens/viewnotifiers/counter_notifier.dart';
import 'package:daily_tracker/services/authentication_service.dart';
import 'package:daily_tracker/services/dialog_service.dart';
import 'package:daily_tracker/shared/ui_helpers.dart';
import '../../locator.dart';
import 'package:flutter/material.dart';
import 'package:provider_architecture/_viewmodel_provider.dart';
import 'package:daily_tracker/shared/shared_styles.dart';

class CounterScreen extends StatelessWidget {

  final int startIndex;

  CounterScreen({this.startIndex});

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<CounterNotifier>.withConsumer(
      viewModelBuilder: () => CounterNotifier(),
      onModelReady: (model) {
        model.startIndex = startIndex;
        model.listenToStreaks();
      },
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
            title: Text(
                model.selectedStreak != null ? model.selectedStreak.name : ''),
            actions: [
              if(model.selectedStreak != null) IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: model.deleteCounter,
              ),
              if(model.streakList != null && model.streakList.length > 0) PopupMenuButton<Streak>(
                icon: Icon(Icons.arrow_drop_down),
                onSelected: (streak) => model.updateToStreak(streak),
                itemBuilder: (context) {
                  return model.streakList.map((Streak streak) {
                    return PopupMenuItem(
                      value: streak,
                      child: Text(streak.name),
                    );
                  }).toList();
                },
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: model.createCounter,
              )
            ]),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: model.selectedStreak == null
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Please create a counter',
                      style: Theme.of(context).textTheme.headline6)
                ])
              : Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Current Streak',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Text(
                      '${model.selectedStreak.currentStreak}',
                      style: HugeNumberStyle,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Highest Streak: ',
                            style: Theme.of(context).textTheme.bodyText2),
                        Text('${model.selectedStreak.prevHighestStreak}',
                            style: LargeNumberStyle),
                      ],
                    ),
                    verticalSpaceLarge,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BusyCheckbox(
                          onPressed: model.markToday,
                          checked: model.checked,
                          busy: model.busy,
                        )
                      ],
                    ),
                  ],
                ),
        ),
        floatingActionButton: model.selectedStreak == null
            ? null
            : FloatingActionButton(
                backgroundColor: BrightBlue,
                tooltip: 'Calendar',
                child: Icon(Icons.calendar_today),
                onPressed: model.navigateToCalendar),
      ),
    );
  }
}
