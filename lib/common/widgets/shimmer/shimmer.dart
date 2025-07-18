import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app_my_app/utils/constants/colors.dart';
import 'package:app_my_app/utils/helper/helper_function.dart';
class TShimmerEffect extends StatelessWidget {
  const TShimmerEffect({super.key,
    required this.width,
    required this.height,
    this.radius =15,
    this.color
  });
final double width,height,radius;
final Color? color;

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    //hieu ung lap lanh
    return Shimmer.fromColors(
        baseColor: dark? Colors.grey[850]! :Colors.grey[300]! ,
        highlightColor: dark? Colors.grey[700]! :Colors.grey[100]! ,
        //widget nay se dc hien thi voi hieu ung lap lanh
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color?? (dark? DColor.darkerGrey: DColor.white),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
    );
  }
}
