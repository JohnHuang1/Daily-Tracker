import 'package:daily_tracker/models/streak.dart';

class IOSWidgetData{
  final List<Streak> streakList;

  IOSWidgetData(this.streakList);

  Map<String, dynamic> toJson() => Map.fromIterable(streakList, key: (e) => streakList.indexOf(e as Streak).toString(), value: (e) => (e as Streak).toJsonWidgetData());

  // IOSWidgetData.fromJson(Map<String, dynamic> json)
  //   : streakList = json.entries.forEach()
}