import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/features/authentication/controller/login/login_controller.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
class TSocialButtons extends StatelessWidget {
  const TSocialButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = LoginController.instance;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        //Google
        Container(
          decoration: BoxDecoration(border: Border.all(color: DColor.grey),
              borderRadius: BorderRadius.circular(100)),
          child: IconButton(
            onPressed: ()=> controller.googleSignIn(),
            icon: const Image(
                width: DSize.iconMd,
                height: DSize.iconMd,
                image: AssetImage(TImages.google)
            ),
          ),
        ),
        const SizedBox(width: DSize.spaceBtwItem,),

        //FaceBook
        Container(
          decoration: BoxDecoration(border: Border.all(color: DColor.grey),
              borderRadius: BorderRadius.circular(100)),
          child: IconButton(
            onPressed: (){},
            icon: const Image(
                width: DSize.iconMd,
                height: DSize.iconMd,
                image: AssetImage(TImages.facebook)
            ),
          ),
        ),
      ],
    );
  }
}