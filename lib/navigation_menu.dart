import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/features/personalization/screens/setting/setting.dart';
import 'package:t_store/features/shop/screens/home/home.dart';
import 'package:t_store/features/shop/screens/wishlist/wishlist.dart';
import 'package:t_store/utils/helper/helper_function.dart';
import 'features/shop/screens/store/store.dart';
class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final dark = DHelperFunctions.isDarkMode(context);
    return Scaffold(
      bottomNavigationBar: Obx(
        ()=>NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index)=> controller.selectedIndex.value = index,
          backgroundColor: dark? Colors.black:Colors.white,
          indicatorColor: dark? Colors.white.withOpacity(0.1):Colors.black.withOpacity(0.1),
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            NavigationDestination(icon: Icon(Iconsax.shop), label: 'Store'),
            NavigationDestination(icon: Icon(Iconsax.heart), label: 'Wishlist'),
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
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
    const SettingScreen()];
  void goToHome() {
    selectedIndex.value = 0;  // Set index for Home screen
  }
}
