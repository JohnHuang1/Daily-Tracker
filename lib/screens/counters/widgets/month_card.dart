import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_tracker/shared/shared_styles.dart';
import 'package:flutter/material.dart';

import 'month_grid.dart';

class MonthCard extends StatefulWidget {
  final bool expanded;
  final int month;
  final int year;
  final List<Timestamp> dates;
  final Function onTap;
  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  MonthCard({
    Key key,
    this.expanded = false,
    @required this.month,
    @required this.dates,
    @required this.year,
    @required this.onTap,
  }) : super(key: key);

  @override
  _MonthCard createState() => _MonthCard();
}

class _MonthCard extends State<MonthCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => widget.onTap(widget.month),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Text(widget.months[widget.month],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 25,
                        )),
                  ),
                  widget.dates.length > 0
                      ? Expanded(
                          child: Text(
                            widget.dates.length.toString(),
                            style: TextStyle(
                              fontFamily: FontNameDefault,
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                              color: NeonGreen,
                            ),
                          ),
                        )
                      : Spacer()
                ],
              ),
            ),
          ),
          if (widget.expanded)
            MonthGrid(
                month: widget.month, year: widget.year, dates: widget.dates),
        ],
      ),
    );
  }
}
