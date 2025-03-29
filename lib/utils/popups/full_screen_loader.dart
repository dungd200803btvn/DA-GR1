import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store_app/common/widgets/loaders/animation_loader.dart';
import 'package:t_store_app/utils/constants/colors.dart';
import 'package:t_store_app/utils/helper/helper_function.dart';
class TFullScreenLoader{

  static void openLoadingDialog(String text,String animation){
    final dark = DHelperFunctions.isDarkMode(Get.context!);
    showDialog(context: Get.overlayContext!,
        barrierDismissible: false, //khong the dong hop thoai bang cach cham ra ngoai
        builder: (_)=> PopScope( //ngan chan dong hop thoai bang dung nut back
          canPop: false,
            child: Container(
              color: dark? DColor.dark:DColor.white ,
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  const SizedBox(height: 250,),

                  Expanded(child: TAnimationLoaderWidget(text: text, animation: animation))
                ],
              ),
            )));
  }
  static stopLoading(){
    Navigator.of(Get.overlayContext!).pop(); //danh rieng de truy cap widget overlay tren cac widget khac nhu pop up,thanh thong bao
}
}
