import 'package:daily_tracker/screens/counters/widgets/month_card.dart';
import 'package:daily_tracker/screens/counters/widgets/year_banner.dart';
import 'package:daily_tracker/screens/viewnotifiers/calendar_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider_architecture/_viewmodel_provider.dart';

class CalendarScreen extends StatelessWidget {
  final int startIndex;

  CalendarScreen({this.startIndex = 0});

  @override
  Widget build(BuildContext context) {
    double mqWidth = MediaQuery.of(context).size.width;
    double mqHeight = MediaQuery.of(context).size.height;
    double bannerSize = 50.0;
    return ViewModelProvider<CalendarNotifier>.withConsumer(
      viewModelBuilder: () => CalendarNotifier(),
      onModelReady: (model) {
        model.setIndex = startIndex;
        model.listenToStreaks();
      },
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text(
              model.selectedStreak != null ? model.selectedStreak.name : ''),
          actions: [
            IconButton(
              icon: model.allExpand ? Icon(Icons.event_available_sharp) : Icon(Icons.event_busy_sharp),
              onPressed: model.expandAll,
            )
          ],
        ),
        body: Container(
          width: mqWidth,
          height: mqHeight,
          child: Stack(
            children: [
              Positioned.fill(
                top: bannerSize,
                right: 0,
                left: 0,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return MonthCard(month: index, dates: model.dates[index], year: model.currentYear, expanded: model.expandedList[index], onTap: model.expand);
                  },
                  itemCount: 12,
                ),
              ),
              YearBanner(
                year: model.currentYear ?? DateTime.now().year,
                onBack: model.selectedStreak != null
                    ? (model.atStartYear() ? null : () => model.updateYear(-1))
                    : () => {},
                onForward: model.selectedStreak != null
                    ? (model.atEndYear() ? null : () => model.updateYear(1))
                    : () => {},
                height: bannerSize,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Calendar',
          child: Icon(Icons.check),
          onPressed: model.navigateToCounter,
        ),
      ),
    );
  }
}
