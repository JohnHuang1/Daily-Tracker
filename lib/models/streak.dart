import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Streak {
  String name;
  final int startYear;
  int prevHighestStreak;
  int currentStreak;
  List<Timestamp> streakDates;

  Streak(
      {@required this.name,
      this.startYear,
      this.prevHighestStreak,
      this.currentStreak,
      this.streakDates});

  Streak.empty({String name = ''})
      : name = name,
        startYear = DateTime.now().year,
        prevHighestStreak = 0,
        currentStreak = 0,
        streakDates = <Timestamp>[];

  static Streak fromStreakJson(Map<String, dynamic> data) {
    List<Timestamp> datesData = List.from(data['dates']);
    if (datesData.length > 0) {
      int beginYear = 0, prevStreak = 0, currStreak = 1;
      datesData.sort();
      DateTime prev = roundToDay(datesData.first.toDate());
      beginYear = prev.year;
      for (Timestamp timestamp in datesData) {
        if(timestamp == datesData.first) continue;
        DateTime current = roundToDay(timestamp.toDate());
        if (prev.add(Duration(hours: 24)).compareTo(current) == 0)
          currStreak++;
        else {
          if (currStreak > prevStreak) prevStreak = currStreak;
          currStreak = 1;
        }
        prev = current;
      }

      if(roundToDay(datesData.last.toDate())
          .add(Duration(hours: 24))
          .isBefore(roundToDay(DateTime.now()))) {
        if (currStreak > prevStreak) prevStreak = currStreak;
        currStreak = 0;
      }
      return Streak(
        name: data['name'],
        startYear: beginYear,
        prevHighestStreak: prevStreak,
        currentStreak: currStreak,
        streakDates: datesData,
      );
    }
    return Streak(
      name: data['name'],
      startYear: DateTime.now().year,
      prevHighestStreak: 0,
      currentStreak: 0,
      streakDates: <Timestamp>[],
    );
  }

  static List<Streak> fromStreakData(List<Map<String, dynamic>> data){
    List<Streak> result = [];
    for(Map<String, dynamic> entry in data){
      result.add(fromStreakJson(entry));
    }
    return result;
  }

  Map<String, dynamic> toJson(){
    return {
      'name': name,
      'dates': streakDates,
    };
  }

  Map<String, dynamic> toJsonWidgetData(){
    return {
      'name': name,
      'prevHighestStreak': prevHighestStreak,
      'currHighestStreak': currentStreak,
      'checked': containsTodaysDate(this),
    };
  }

  static DateTime roundToDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static bool containsTodaysDate(Streak streak){
    if(streak.streakDates.length > 0) return streak.streakDates.last.compareTo(Timestamp.fromDate(roundToDay(DateTime.now()))) > -1;
    return false;
  }
}
