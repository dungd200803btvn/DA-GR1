import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DHelperFunctions{
  static Color? getColor(String value){
    if(value=="Green"){
      return Colors.green;
    }else if(value=="Red"){
      return Colors.red;
    }else if(value=="Blue"){
      return Colors.blue;
    }else if(value=="Pink"){
      return Colors.pink;
    }else if(value=="Grey"){
      return Colors.grey;
    }else if(value=="Purple"){
      return Colors.purple;
    }else if(value=="Black"){
      return Colors.black;
    }else if(value=="White"){
      return Colors.white;
    }else if(value=="Brown"){
      return Colors.brown;
    }else if(value=="Teal"){
      return Colors.teal;
    }else if(value=="Indigo"){
      return Colors.indigo;
    }else if(value=="Yellow"){
      return Colors.yellow;
    }else if(value=="Orange"){
      return Colors.deepOrange;
    }else if(value=="Silver"){
      return const Color(0xffc0c0c0);;
    }else{
      return null;
    }
  }
  static void showSnackbar(String message){
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  static void showAlert(String title,String message){
    showDialog(context: Get.context!, builder: (BuildContext context){
      return AlertDialog(
          title: Text(title),
          content: Text(message),
        actions: [
          TextButton(onPressed: ()=> Navigator.of(context).pop(),
              child: const Text("OK"))
        ],
      );
    });
  }
  static void navigateToScreen(BuildContext context,Widget screen){
    Navigator.push(context,
        MaterialPageRoute(builder: (_)=> screen));
  }
  static String truncateText(String text,int maxLength){
    if(text.length<=maxLength){
      return text;
    }else{
      return '${text.substring(0,maxLength)}...';
    }
  }
  static bool isDarkMode(BuildContext context){
    return Theme.of(context).brightness == Brightness.dark;
  }
  static Size screenSize(){
    return  MediaQuery.of(Get.context!).size;
}
  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }
static List<T> removeDuplicate<T>(List<T> list){
    return list.toSet().toList();
}
static List<Widget> wrapWidgets(List<Widget> widgets,int rowsize){
    final wrapperList = <Widget>[];
    for(var i=0;i<widgets.length;i+=rowsize){
      final rowChildren  = widgets.sublist(i,i+rowsize>widgets.length?widgets.length:i+rowsize);
      wrapperList.add(Row(children: rowChildren,));
    }
    return wrapperList;
  }
}