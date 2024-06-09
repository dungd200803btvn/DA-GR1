import 'package:flutter/material.dart';
import 'package:t_store/common/widgets/shimmer/shimmer.dart';
import 'package:t_store/utils/constants/sizes.dart';
class TBoxesShimmer extends StatelessWidget {
  const TBoxesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TShimmerEffect(width: 150, height: 110),
        ),
        SizedBox(width: DSize.spaceBtwItem),
        Expanded(
          child: TShimmerEffect(width: 150, height: 110),
        ),
        SizedBox(width: DSize.spaceBtwItem),
        Expanded(
          child: TShimmerEffect(width: 150, height: 110),
        ),
      ],
    );
  }
}
