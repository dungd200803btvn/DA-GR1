import 'package:flutter/material.dart';
import 'package:app_my_app/common/widgets/shimmer/shimmer.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
class TListTileShimmer extends StatelessWidget {
  const TListTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            TShimmerEffect(width: 50, height: 50,radius: 50,),
          SizedBox( width: DSize.spaceBtwItem,),
            Column(
              children: [
                TShimmerEffect(width: 100, height: 15),
                SizedBox(height: DSize.spaceBtwItem/2,),
                TShimmerEffect(width: 80, height: 12)
              ],
            )
          ],
        )
      ],
    );
  }
}
