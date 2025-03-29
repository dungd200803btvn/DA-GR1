import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store_app/common/widgets/shimmer/shimmer.dart';
import 'package:t_store_app/features/personalization/controllers/user_controller.dart';
import 'package:t_store_app/features/shop/screens/cart/cart.dart';
import 'package:t_store_app/l10n/app_localizations.dart';
import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/products/cart/cart_menu_icon.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/text_string.dart';
class THomeAppBar extends StatelessWidget {
  const THomeAppBar({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final lang =  AppLocalizations.of(context);
    return TAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.translate('homeAppbarTitle'),
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .apply(color: DColor.grey),
          ),
          Obx(
            () {
              if(controller.profileLoading.value){
                return const TShimmerEffect(width: 80, height: 15);
              }else{
                return Obx(
                  ()=> Text(
                    controller.user.value.fullname,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .apply(color: DColor.white),
                  ),
                );
              }

            }
          ),
        ],
      ),
      actions: const [
        TCartCounterIcon(
          iconColor: DColor.white,
          counterBgColor: DColor.black,
          counterTextColor: Colors.white,
        )
      ],
    );
  }
}