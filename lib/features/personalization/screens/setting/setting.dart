import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:t_store/common/widgets/list_tiles/setting_menu_tile.dart';
import 'package:t_store/common/widgets/texts/section_heading.dart';
import 'package:t_store/data/repositories/authentication/authentication_repository.dart';
import 'package:t_store/features/personalization/screens/address/address.dart';
import 'package:t_store/features/review/screen/review_screen.dart';
import 'package:t_store/features/shop/screens/cart/cart.dart';
import 'package:t_store/features/shop/screens/order/order.dart';
import 'package:t_store/features/shop/screens/product_reviews/product_review.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';

import '../../../../api/ShippingService.dart';
import '../../../../common/widgets/list_tiles/user_profile_tile.dart';
import '../../../../data/repositories/vouchers/VoucherRepository.dart';
import '../../../notification/controller/notification_controller.dart';
import '../../../notification/screen/notification_screen.dart';
import '../../../setting/screen/language_settings.dart';
import '../../../voucher/screens/voucher.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          //Header
          TPrimaryHeaderContainer(
              child: Column(
            children: [
              TAppBar(
                title: Text('Account',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .apply(color: DColor.white)),
              ),
              const SizedBox(height: DSize.spaceBtwSection),

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
                const TSectionHeading(
                    title: 'Account Setting', showActionButton: false),
                const SizedBox(height: DSize.spaceBtwItem),
                 TSettingMenuTile(
                    icon: Iconsax.safe_home,
                    title: 'My Addresses',
                    subTitle: 'Set shopping delivery addresses',
                onTap: ()=> Get.to(()=>const UserAddressScreen())),
                 TSettingMenuTile(
                    icon: Iconsax.shopping_cart,
                    title: 'My Cart',
                    subTitle: 'Add, remove products and move to checkout',
                onTap: ()=> Get.to(()=>const CartScreen() ,),),
                 TSettingMenuTile(
                    icon: Iconsax.bag_tick,
                    title: 'My Orders',
                    subTitle: 'In progress and completed orders',
                  onTap: ()=> Get.to(()=>const OrderScreen()) ,),
                TSettingMenuTile(
                    icon: Iconsax.bank,
                    title: 'Bank Account',
                    subTitle: 'Withdraw balance to registered bank account',
                  onTap: ()=> Get.to(()=> const LanguageSelectorScreen( )) ,
                ),
                TSettingMenuTile(
                    icon: Iconsax.discount_shape,
                    title: 'My Coupons',
                    subTitle: 'List of all discounted coupons',
                  onTap: ()=> Get.to(()=>VoucherScreen( userId: AuthenticationRepository.instance.authUser!.uid,)) ,
                ),

                TSettingMenuTile(
                    icon: Iconsax.notification,
                    title: 'Notifications',
                    subTitle: 'Set any kind of notification messages',
                  onTap: ()=> Get.to(()=>const NotificationScreen( )) ,),
                TSettingMenuTile(
                    icon: Iconsax.security_card,
                    title: 'Account Privacy',
                    subTitle: 'Manage data usage and connected accounts',

                ),

                //App Settings
                const SizedBox(height: DSize.spaceBtwSection),
                const TSectionHeading(
                    title: 'App Settings', showActionButton: false),
                const SizedBox(height: DSize.spaceBtwItem),
                const TSettingMenuTile(
                    icon: Iconsax.notification,
                    title: 'Load data',
                    subTitle: 'Upload data to your cloud firebase'),
                TSettingMenuTile(
                  icon: Iconsax.location,
                  title: 'GeoLocation',
                  subTitle: 'Set recommendation based on location',
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),

                TSettingMenuTile(
                  icon: Iconsax.security_user,
                  title: 'Safe mode',
                  subTitle: 'Search result is safe for all ages',
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),
                TSettingMenuTile(
                  icon: Iconsax.image,
                  title: 'HD Image Quality',
                  subTitle: 'Set image quality to be seen',
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),

                //Logout Button
                const SizedBox(height: DSize.spaceBtwSection),
                SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final shippingService = ShippingOrderService();
                        await shippingService.createShippingOrder();
                        AuthenticationRepository.instance.logout();

                      }  ,
                      child: const Text('Logout'),
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
