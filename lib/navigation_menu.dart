import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:my_app/features/notification/screen/notification_screen.dart';
import 'package:my_app/features/personalization/screens/setting/setting.dart';
import 'package:my_app/features/shop/screens/home/home.dart';
import 'package:my_app/features/shop/screens/wishlist/wishlist.dart';
import 'package:my_app/l10n/app_localizations.dart';
import 'package:my_app/utils/helper/helper_function.dart';
import 'features/notification/widget/notification_icon.dart';
import 'features/shop/screens/store/store.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final dark = DHelperFunctions.isDarkMode(context);
    final lang = AppLocalizations.of(context);
    final FirebaseAnalytics analytics =  FirebaseAnalytics.instance;
    final List pageNames = [lang.translate('home'),lang.translate('store'),lang.translate('wishlist'),lang.translate('notification'),lang.translate('profile')];
    analytics.setAnalyticsCollectionEnabled(true);
    return Scaffold(
      bottomNavigationBar: Obx(
        ()=>NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) async{
            await analytics.logEvent(name: 'pages_tracked',
            parameters: {
              "page_name": pageNames[index],
              "page_index":index
            });
            controller.selectedIndex.value = index;
          },
          backgroundColor: dark? Colors.black:Colors.white,
          indicatorColor: dark? Colors.white.withOpacity(0.1):Colors.black.withOpacity(0.1),
          destinations: [
            NavigationDestination(icon: Icon(Iconsax.home), label: lang.translate('home')),
            NavigationDestination(icon: Icon(Iconsax.shop), label:  lang.translate('store')),
            NavigationDestination(icon: Icon(Iconsax.heart), label: lang.translate('wishlist')),
            // Mục Notification với badge
            NavigationDestination(
                icon: NotificationIcon(),
                label: lang.translate('notification')),
            NavigationDestination(icon: Icon(Iconsax.user), label: lang.translate('profile')),
          ],
        ),
      ),
      body: Obx(()=> Container(child: controller.screens[controller.selectedIndex.value],)),
    );
  }
}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs;
  final screens = [
    const HomeScreen(),
    const StoreScreen(),
    const FavouriteScreen(),
    const NotificationScreen(showBackArrow: false,),
    const SettingScreen()];
  void goToHome() {
    selectedIndex.value = 0;  // Set index for Home screen
  }
}
