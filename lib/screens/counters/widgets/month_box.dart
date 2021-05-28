import 'package:daily_tracker/shared/shared_styles.dart';
import 'package:flutter/material.dart';

class MonthBox extends StatelessWidget {
  final int visibility;
  final Color fillColor;
  final double size;
  final int day;

  const MonthBox({
    Key key,
    @required this.visibility,
    this.fillColor = NeonGreen,
    this.size = 20, this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: visibility == -1 ? Border() : Border.all(),
        color: visibility == 1 ? fillColor : Colors.transparent,
      ),
      child: visibility != -1 ? Center(
        child: Text(day.toString() ?? ""),
      ) : null,
    );
  }
}
