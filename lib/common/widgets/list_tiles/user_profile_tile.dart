import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:my_app/features/personalization/controllers/user_controller.dart';
import 'package:my_app/features/personalization/screens/profile/profile.dart';
import '../../../utils/constants/colors.dart';
import '../images/t_circular_image.dart';
class TUserProfileTile extends StatelessWidget {
  const TUserProfileTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return ListTile(
      leading:  Obx(
          ()=> TCircularImage(
            image: controller.user.value.profilePicture, width: 50, height: 50, padding: 0,isNetworkImage: controller.user.value.profilePicture.isNotEmpty,fit: BoxFit.cover,),
      ),
      title: Obx(
          ()=> Text(controller.user.value.fullname,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(color: DColor.white)),
      ),
      subtitle: Obx(
            ()=> Text(controller.user.value.email,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .apply(color: DColor.white)),
      ),
      trailing: IconButton(
          onPressed: ()=> Get.to( const ProfileScreen()),
          icon: const Icon(Iconsax.edit, color: DColor.white)),
    );
  }
}