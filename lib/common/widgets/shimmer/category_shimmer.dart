import 'package:flutter/material.dart';
import 'package:lcd_ecommerce_app/common/widgets/shimmer/shimmer.dart';
import 'package:lcd_ecommerce_app/utils/constants/sizes.dart';
class TCategoryShimmer extends StatelessWidget {
  const TCategoryShimmer({super.key,
     this.itemCount =6});
final int itemCount;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
          itemBuilder: (_,__){
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Image
                TShimmerEffect(width: 55, height: 55,radius: 55,),
                SizedBox(height: DSize.spaceBtwItem/2,),
                //Text
                TShimmerEffect(width: 55, height: 8),
              ],
            );
          },
          separatorBuilder: (_,__)=> const SizedBox(width: DSize.spaceBtwItem,),
          itemCount: itemCount,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,),
    );
  }
}
