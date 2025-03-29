import 'package:flutter/material.dart';
import 'package:lcd_ecommerce_app/utils/constants/colors.dart';
class TShadowStyle{
  static final verticalProductShadow = BoxShadow(
    color: DColor.darkGrey.withOpacity(0.1),//do mo 10 %
    blurRadius: 50,  //muc do sac net cua cac canh
    spreadRadius: 7, //ban kinh lan rong
    offset: const Offset(0,2)
  );
  static final horizontalProductShadow = BoxShadow(
      color: DColor.darkGrey.withOpacity(0.1),
      blurRadius: 50,
      spreadRadius: 7,
      offset: const Offset(0,2)
  );
}