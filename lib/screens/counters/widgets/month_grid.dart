import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'month_box.dart';

class MonthGrid extends StatelessWidget{
  final int month;
  final int year;
  final List<Timestamp> dates;

  const MonthGrid({Key key, this.month, this.year, this.dates}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int startWeekday = DateTime(year, month + 1).weekday;
    int dayTotal = DateUtils.getDaysInMonth(year, month + 1);
    List<int> values = List.generate(startWeekday == 7 ? 0 : startWeekday, (index) => -1);
    int counter = 0;
    values.addAll(List.generate(dayTotal, dates != null && dates.length > 0 ? (index) {
      if(counter < dates.length && _sameDay(dates[counter], DateTime(year, month + 1, index + 1))){
        counter++;
        return 1;
      }
      return 0;
    } : (index) {return 0;}));
    return AbsorbPointer(
      absorbing: true,
      child: Center(
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: values.length,
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemBuilder: (context, index){
            // return Center(child: MonthBox(visibility: values[index],));
            return MonthBox(visibility: values[index], day: index - startWeekday + 1);
          },
        ),
      ),
    );
  }

  bool _sameDay(Timestamp time, DateTime date){
    DateTime d = time.toDate();
    return DateTime(d.year, d.month, d.day).isAtSameMomentAs(date);
  }

}