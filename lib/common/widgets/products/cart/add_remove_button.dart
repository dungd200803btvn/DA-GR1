import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helper/helper_function.dart';
import '../../icons/t_circular_icon.dart';
class TProductQuantityWithAddRemoveButton extends StatelessWidget {
  const TProductQuantityWithAddRemoveButton({
    super.key, required this.quantity, this.add, this.remove,
  });
final int quantity;
final VoidCallback? add,remove;
  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    return Row(
      children: [
        TCircularIcon(
          icon: Iconsax.minus,
          width: 32,
          height: 32,
          size: DSize.md,
          color: dark ? DColor.white : DColor.black,
          backgroundColor: dark ? DColor.darkerGrey : DColor.light,
          onPressed: remove,
        ),
        const SizedBox(
          width: DSize.spaceBtwItem,
        ),
        Text(
          quantity.toString(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(
          width: DSize.spaceBtwItem,
        ),
        TCircularIcon(
            icon: Iconsax.add,
            width: 32,
            height: 32,
            size: DSize.md,
            color: dark ? DColor.white : DColor.black,
            backgroundColor: DColor.primary,
            onPressed: add,),
      ],
    );
  }
}
