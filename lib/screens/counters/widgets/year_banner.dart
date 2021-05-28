import 'package:flutter/material.dart';

class YearBanner extends StatefulWidget {
  final int year;
  final Function onBack, onForward;
  final double height;

  const YearBanner({Key key, @required this.year, @required this.onBack, @required this.onForward, this.height}) : super(key: key);

  @override
  _YearBanner createState() => _YearBanner();
}

class _YearBanner extends State<YearBanner>{
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_sharp),
            onPressed: widget.onBack,
            disabledColor: Colors.grey,
          ),
          Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            child: Text(widget.year.toString()),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_sharp),
            onPressed: widget.onForward,
            disabledColor: Colors.grey,
          ),
        ],
      ),
    );
  }

}