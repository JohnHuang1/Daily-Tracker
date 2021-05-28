import 'package:flutter/material.dart';

// Colors
const Color NeonGreen = Color(0xff04e762);
const Color OrangeYellow = Color(0xffF5B700);
const Color RedPurple = Color(0xffDC0073);
const Color BrightBlue = Color(0xff008BF8);
const Color LawnGreen = Color(0xff89FC00);
const Color DarkColor = Color(0xff1e1e24);
const Color GrayColor = Color(0xff444140);
const Color ShrimpColor = Color(0xffffa987);
const Color SoftRedColor = Color(0xffe54b4b);

// Box Decorations

BoxDecoration fieldDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(5), color: Colors.grey[200]);

BoxDecoration disabledFieldDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(5), color: Colors.grey[100]);

// Field Variables

const double fieldHeight = 55;
const double smallFieldHeight = 40;
const double inputFieldBottomMargin = 30;
const double inputFieldSmallBottomMargin = 0;
const EdgeInsets fieldPadding = const EdgeInsets.symmetric(horizontal: 15);
const EdgeInsets largeFieldPadding = const EdgeInsets.symmetric(horizontal: 15, vertical: 15);

// Text Variables
const String FontNameDefault = 'Montserrat';
const HugeTextSize = 100.0;
const LargeTextSize = 30.0;
const MediumTextSize = 16.0;
const SmallTextSize = 12.0;

const TextStyle buttonTitleTextStyle = const TextStyle(fontWeight: FontWeight.w700, color: Colors.white);
const AppBarTextStyle = TextStyle(
  fontFamily: FontNameDefault,
  fontWeight: FontWeight.w600,
  fontSize: 25.0,
  color: Colors.white,
);

const HugeNumberStyle = TextStyle(
  fontFamily: FontNameDefault,
  fontWeight: FontWeight.w600,
  fontSize: HugeTextSize,
  color: NeonGreen
);

const LargeNumberStyle = TextStyle(
    fontFamily: FontNameDefault,
    fontWeight: FontWeight.w600,
    fontSize: LargeTextSize,
    color: NeonGreen
);

const TitleTextStyle = TextStyle(
    fontFamily: FontNameDefault,
    fontWeight: FontWeight.w300,
    fontSize: LargeTextSize,
    color: Colors.black
);

const BodyText2TextStyle = TextStyle(
    fontFamily: FontNameDefault,
    fontWeight: FontWeight.w300,
    fontSize: MediumTextSize,
    color: Colors.black
);

const Subtitle2TextStyle = TextStyle(
    fontFamily: FontNameDefault,
    fontWeight: FontWeight.w300,
    fontSize: SmallTextSize,
    color: Colors.black
);
