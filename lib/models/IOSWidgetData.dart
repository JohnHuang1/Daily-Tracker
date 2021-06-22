

import 'package:daily_tracker/models/streak.dart';

class IOSWidgetData{
  final List<Streak> streakList;
  final DateTime lastUpdated;

  IOSWidgetData(this.streakList, this.lastUpdated);
  Map<String, dynamic> toJson() {

    List<Map> str = streakList.isNotEmpty ? streakList.map((streak) => streak.toJsonWidgetData()).toList() : null;

    return {
      "streakList": str,
      "lastUpdated": lastUpdated
    };
  }
}