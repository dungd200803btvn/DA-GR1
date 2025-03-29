import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store_app/common/widgets/appbar/appbar.dart';
import 'package:t_store_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:t_store_app/common/widgets/list_tiles/setting_menu_tile.dart';
import 'package:t_store_app/common/widgets/texts/section_heading.dart';
import 'package:t_store_app/data/repositories/authentication/authentication_repository.dart';
import 'package:t_store_app/features/bonus_point/screens/daily_checkin_screen.dart';
import 'package:t_store_app/features/payment/screens/payment_test.dart';
import 'package:t_store_app/features/personalization/screens/address/address.dart';
import 'package:t_store_app/features/review/screen/review_screen.dart';
import 'package:t_store_app/features/shop/screens/cart/cart.dart';
import 'package:t_store_app/features/shop/screens/order/order.dart';
import 'package:t_store_app/features/shop/screens/product_reviews/product_review.dart';
import 'package:t_store_app/utils/constants/colors.dart';
import 'package:t_store_app/utils/constants/sizes.dart';

import '../../../../api/ShippingService.dart';
import '../../../../common/widgets/list_tiles/user_profile_tile.dart';
import '../../../../data/repositories/vouchers/VoucherRepository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../notification/controller/notification_controller.dart';
import '../../../notification/screen/notification_screen.dart';
import '../../../setting/screen/language_settings.dart';
import '../../../voucher/screens/voucher.dart';
import '../../controllers/user_controller.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    final user = UserController.instance.user.value;
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          //Header
          TPrimaryHeaderContainer(
              child: Column(
            children: [
              TAppBar(
                title: Text(lang.translate('account'),
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .apply(color: DColor.white)),
              ),
              //UserProfile card
              const TUserProfileTile(),
              const SizedBox(height: DSize.spaceBtwSection),
            ],
          )),
          //Body
          Padding(
            padding: const EdgeInsets.all(DSize.defaultspace),
            child: Column(
              children: [
                //Account Setting
                 TSectionHeading(
                    title: lang.translate('account_in4'), showActionButton: false),
                const SizedBox(height: DSize.spaceBtwItem),
                 TSettingMenuTile(
                    icon: Iconsax.safe_home,
                    title: lang.translate('my_address'),
                    subTitle: lang.translate('my_address_msg'),
                onTap: ()=> Get.to(()=>const UserAddressScreen())),
                 TSettingMenuTile(
                    icon: Iconsax.shopping_cart,
                   title: lang.translate('my_cart'),
                   subTitle: lang.translate('my_cart_msg'),
                onTap: ()=> Get.to(()=>const CartScreen() ,),),
                 TSettingMenuTile(
                    icon: Iconsax.bag_tick,
                   title: lang.translate('my_order'),
                   subTitle: lang.translate('my_order_msg'),
                  onTap: ()=> Get.to(()=>const OrderScreen()) ,),

                TSettingMenuTile(
                    icon: Iconsax.discount_shape,
                  title: lang.translate('my_coupon'),
                  subTitle: lang.translate('my_coupon_msg'),
                  onTap: ()=> Get.to(()=>VoucherScreen( userId: AuthenticationRepository.instance.authUser!.uid,)) ,
                ),

                TSettingMenuTile(
                    icon: Iconsax.notification,
                  title: lang.translate('my_notification'),
                  subTitle: lang.translate('my_notification_msg'),
                  onTap: ()=> Get.to(()=>const NotificationScreen( )) ,),

                TSettingMenuTile(
                  icon: Icons.monetization_on,
                  title: lang.translate('my_bonus_point'),
                  subTitle: lang.translate('my_bonus_point_msg'),
                  onTap: ()=> Get.to(()=>DailyCheckInScreen(currentUser: user, )) ,),
                //App Settings
                const SizedBox(height: DSize.spaceBtwSection),
                TSectionHeading(
                    title: lang.translate('app_setting'), showActionButton: false),
                const SizedBox(height: DSize.spaceBtwItem),
                TSettingMenuTile(
                  icon: Icons.language,
                  title: lang.translate('my_language'),
                  subTitle: lang.translate('my_language_msg'),
                  onTap: ()=> Get.to(()=> const LanguageSelectorScreen( )) ,
                ),

                TSettingMenuTile(
                  icon: Icons.dark_mode,
                  title: lang.translate('dark_mode'),
                  subTitle: lang.translate('dark_mode_msg'),
                  trailing: Switch(
                    // Dùng Get.isDarkMode để lấy trạng thái chủ đề hiện tại của ứng dụng
                    value: Get.isDarkMode,
                    onChanged: (bool value) {
                      // Thay đổi chủ đề chỉ trong ứng dụng khi người dùng toggle switch
                      Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ),

                //Logout Button
                const SizedBox(height: DSize.spaceBtwSection),
                SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        AuthenticationRepository.instance.logout();
                      }  ,
                      child: Text(lang.translate('log_out')),
                    )),
                const SizedBox(height: DSize.spaceBtwSection * 2.5),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
