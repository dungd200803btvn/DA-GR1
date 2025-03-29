import 'package:get/get.dart';
import 'package:lcd_ecommerce_app/features/authentication/screens/login/login.dart';
import 'package:lcd_ecommerce_app/features/authentication/screens/onboarding/onboard_screen.dart';
import 'package:lcd_ecommerce_app/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:lcd_ecommerce_app/features/authentication/screens/signup/signup.dart';
import 'package:lcd_ecommerce_app/features/authentication/screens/signup/verify_email.dart';
import 'package:lcd_ecommerce_app/features/personalization/screens/address/address.dart';
import 'package:lcd_ecommerce_app/features/personalization/screens/profile/profile.dart';
import 'package:lcd_ecommerce_app/features/personalization/screens/setting/setting.dart';
import 'package:lcd_ecommerce_app/features/shop/screens/cart/cart.dart';
import 'package:lcd_ecommerce_app/features/shop/screens/checkout/checkout.dart';
import 'package:lcd_ecommerce_app/features/shop/screens/home/home.dart';
import 'package:lcd_ecommerce_app/features/shop/screens/order/order.dart';
import 'package:lcd_ecommerce_app/features/shop/screens/product_reviews/product_review.dart';
import 'package:lcd_ecommerce_app/features/shop/screens/store/store.dart';
import 'package:lcd_ecommerce_app/features/shop/screens/wishlist/wishlist.dart';
import 'package:lcd_ecommerce_app/routes/routes.dart';

class AppRoutes{
  static final  pages = [
    GetPage(name: TRoutes.home, page: ()=> const HomeScreen()),
    GetPage(name: TRoutes.store, page: ()=> const StoreScreen()),
    GetPage(name: TRoutes.favourites, page: ()=>const FavouriteScreen()),
    GetPage(name: TRoutes.settings, page: ()=> const SettingScreen()),
    GetPage(name: TRoutes.order, page: ()=> const OrderScreen()),
    GetPage(name: TRoutes.checkout, page: ()=> const CheckoutScreen()),
    GetPage(name: TRoutes.cart, page: ()=> const CartScreen()),
    GetPage(name: TRoutes.userProfile, page: ()=>const ProfileScreen()),
    GetPage(name: TRoutes.userAddress, page: ()=> const UserAddressScreen()),
    GetPage(name: TRoutes.signup, page: ()=> const Signup()),
    GetPage(name: TRoutes.verifyEmail, page: ()=> const VerifyEmailScreen()),
    GetPage(name: TRoutes.signIn, page: ()=> const LoginScreen()),
    GetPage(name: TRoutes.forgetPassword, page: ()=> const ForgetPassword()),
    GetPage(name: TRoutes.onBoarding, page: ()=> const OnBoardingScreen()),

  ];
}