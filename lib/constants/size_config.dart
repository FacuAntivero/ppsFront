import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static double? defaultSize;
  static Orientation? orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
  }
}

double xxxl() {
  return SizeConfig.screenWidth * 0.2;
}

double xxl() {
  return SizeConfig.screenWidth * 0.1;
}

double xl() {
  return SizeConfig.screenWidth * 0.08;
}

double lg() {
  return SizeConfig.screenWidth * 0.07;
}

double md() {
  return SizeConfig.screenWidth * 0.06;
}

double sm() {
  return SizeConfig.screenWidth * 0.05;
}

double xs() {
  return SizeConfig.screenWidth * 0.04;
}

double xxs() {
  return SizeConfig.screenWidth * 0.035;
}

double xxxs() {
  return SizeConfig.screenWidth * 0.032;
}
