import 'package:flutter/material.dart';
import 'package:t_store_app/common/widgets/shimmer/shimmer.dart';
import 'package:t_store_app/utils/constants/sizes.dart';

class THorizontalProductShimmer extends StatelessWidget {
  const THorizontalProductShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DSize.defaultspace),
      height: 120,
      child: ListView.separated(
        itemBuilder: (_, __) => const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Image
            TShimmerEffect(width: 120, height: 120),
            SizedBox(
              width: DSize.spaceBtwItem,
            ),
            //Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: DSize.spaceBtwItem / 2,
                ),
                TShimmerEffect(width: 160, height: 15),
                SizedBox(
                  width: DSize.spaceBtwItem / 2,
                ),
                TShimmerEffect(width: 110, height: 15),
                SizedBox(
                  width: DSize.spaceBtwItem / 2,
                ),
                TShimmerEffect(width: 80, height: 15),
                Spacer(),
              ],
            )
          ],
        ),
        separatorBuilder: (context, index) => const SizedBox(
          width: DSize.spaceBtwItem,
        ),
        itemCount: itemCount,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
