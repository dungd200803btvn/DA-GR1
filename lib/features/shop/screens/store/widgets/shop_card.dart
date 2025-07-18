import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../common/widgets/texts/t_branc_title_text_with_verified_icon.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/shop_model.dart';

class ShopCard extends StatelessWidget {
  const ShopCard({
    super.key,
    required this.showBorder,
    this.onTap, required this.shop,
  });
  final ShopModel shop;
  final bool showBorder;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: TRoundedContainer(
        padding: const EdgeInsets.all(DSize.sm),
        showBorder: showBorder,
        backgroundColor: Colors.transparent,
        child: Row(
          children: [
            const SizedBox(width: DSize.spaceBtwItem / 2),
            //Text
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TBrandTitleWithVerifiedIcon(
                      title: shop.name, branchTextSize: TTextSize.largre),
                  Text('${shop.productCount?? 0} ${lang.translate('products')}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}