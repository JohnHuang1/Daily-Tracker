

import 'package:daily_tracker/models/streak.dart';

class IOSWidgetData{
  final List<Streak> streakList;

  IOSWidgetData(this.streakList);
  Map<String, dynamic> toJson() {

    List<Map> str = streakList.isNotEmpty ? streakList.map((streak) => streak.toJsonWidgetData()).toList() : null;

    return {
      "streakList": str
    };
  }
}