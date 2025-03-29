import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store_app/common/widgets/texts/t_branch_title_text.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/sizes.dart';

class TBrandTitleWithVerifiedIcon extends StatelessWidget {
  const TBrandTitleWithVerifiedIcon({
    super.key,
    required this.title,
    this.maxLines = 1,
    this.textColor,
    this.iconColor = DColor.primary,
    this.textAlign = TextAlign.center,
    this.branchTextSize = TTextSize.small,
  });

  final String title;
  final int maxLines;
  final Color? textColor, iconColor;
  final TextAlign textAlign;
  final TTextSize branchTextSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: TBranchTitleText(
            title: title,
            color: textColor,
            textAlign: textAlign,
            branchTextSize: branchTextSize,
            maxLines: maxLines,
          ),
        ),
        const SizedBox(width: DSize.xs),
        Icon(Iconsax.verify5, color: iconColor, size: DSize.iconXs),
      ],
    );
  }
}
