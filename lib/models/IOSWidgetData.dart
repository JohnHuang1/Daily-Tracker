import 'dart:convert';

import 'package:daily_tracker/models/streak.dart';

class IOSWidgetData{
  final List<Streak> streakList;

  IOSWidgetData(this.streakList);

  // Map<String, dynamic> toJson() => Map.fromIterable(streakList, key: (e) => streakList.indexOf(e as Streak).toString(), value: (e) => (e as Streak).toJsonWidgetData());

  Map<String, dynamic> toJson() => {"streakList": jsonEncode(streakList)};
  // IOSWidgetData.fromJson(Map<String, dynamic> json)
  //   : streakList = json.entries.forEach()
}