import 'package:flutter/material.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
class TSpacingStyle{
  static const EdgeInsetsGeometry paddingWithAppbarHeight  = EdgeInsets.only(
    top:DSize.appbarHeight,
    bottom: DSize.defaultspace,
    left: DSize.defaultspace,
    right: DSize.defaultspace,
  );
}