import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../screens/login/login.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance =>
      Get.find(); //khai bao 1 lan sau do se tim lai
//variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;//tu dong bao cho widget cap nhat su thay doi khi gia tri bien quan sat thay doi
  void updatePageIndicator(index) {
    currentPageIndex.value = index;
  }

  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }
  void nextButton(){
    if(currentPageIndex.value == 2){
      final storage = GetStorage();
      if(kDebugMode){
        print('==================GET STORAGE===================');
        print(storage.read('isFirstTime'));
      }
      storage.write('isFirstTime',false);
      if(kDebugMode){
        print('==================GET STORAGE===================');
        print(storage.read('isFirstTime'));
      }
      Get.offAll(const LoginScreen());
    }
    else{
      int page = currentPageIndex.value+1;
      pageController.jumpToPage(page);
    }
  }
  void skipButton(){
    if(currentPageIndex.value == 2){
      //Get.to(LoginScreen());
    }
    else{
      int page = 2;
      pageController.jumpToPage(page);
    }
  }
}
