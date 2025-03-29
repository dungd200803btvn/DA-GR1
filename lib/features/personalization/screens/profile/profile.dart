import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store_app/common/widgets/appbar/appbar.dart';
import 'package:t_store_app/common/widgets/images/t_circular_image.dart';
import 'package:t_store_app/common/widgets/shimmer/shimmer.dart';
import 'package:t_store_app/common/widgets/texts/section_heading.dart';
import 'package:t_store_app/features/personalization/screens/profile/widgets/change_field.dart';
import 'package:t_store_app/features/personalization/screens/profile/widgets/change_name.dart';
import 'package:t_store_app/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:t_store_app/utils/constants/image_strings.dart';
import 'package:t_store_app/utils/constants/sizes.dart';
import 'package:t_store_app/utils/formatter/formatter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../controllers/user_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar:  TAppBar(showBackArrow: true, title: Text(lang.translate('profile'),style: Theme.of(context).textTheme.headlineSmall)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          child: Column(
            children: [
              //Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = controller.user.value.profilePicture;
                      final image = networkImage.isNotEmpty? networkImage: TImages.user;
                      return  controller.imageUploading.value? const TShimmerEffect(width: 80, height:80,radius: 80,):
                        TCircularImage(
                          image: image, width: 100, height: 100,isNetworkImage: networkImage.isNotEmpty,);
                    }),
                    TextButton(
                        onPressed: () => controller.uploadUserProfilePicture(),
                        child:  Text(lang.translate('change_pro5_picture'))),
                  ],
                ),
              ),

              //Detail
              const SizedBox(height: DSize.spaceBtwItem / 2),
              const Divider(),
              const SizedBox(height: DSize.spaceBtwItem),
              //Heading Profile Info
               TSectionHeading(
                  title: lang.translate('profile_in4'), showActionButton: false),
              const SizedBox(height: DSize.spaceBtwItem),
              Obx(() => TProfileMenu(
                  onPressed: () => Get.to(() => const ChangeName()),
                  title: lang.translate('name'),
                  value: controller.user.value.fullname)),
              Obx(() => TProfileMenu(
                  onPressed: () {
                    Get.to(()=> ChangeProfileField(
                      title: lang.translate('change_user'),
                      successMessage: lang.translate('change_user_msg'),
                      fields: [
                        FieldConfig(
                          label: 'username',
                          fieldName: 'UserName',
                          fieldType: FieldType.text,
                          textController: TextEditingController(text: ""),
                        ),
                      ],
                      onUpdate: (data) async {
                        await controller.updateSingleField(data);
                      },
                    ));
                  },
                  title: lang.translate('username'),
                  value: controller.user.value.userName)),
              const SizedBox(height: DSize.spaceBtwItem),
              const Divider(),
              const SizedBox(height: DSize.spaceBtwItem),
              //Heading Personal Info
               TSectionHeading(
                  title: lang.translate('personal_in4'), showActionButton: false),
              const SizedBox(height: DSize.spaceBtwItem),
              Obx(() => TProfileMenu(
                  onPressed: () {
                    Get.to(()=> ChangeProfileField(
                      title: lang.translate('change_email'),
                      successMessage: lang.translate('change_email_msg'),
                      fields: [
                        FieldConfig(
                          label: 'email',
                          fieldName: 'Email',
                          fieldType: FieldType.text,
                          textController: TextEditingController(text: ""),
                        ),
                      ],
                      onUpdate: (data) async {
                        await controller.updateSingleField(data);
                      },
                    ));
                  },
                  title: lang.translate('email'),
                  value: controller.user.value.email)),
              Obx(() => TProfileMenu(
                  onPressed: () {
                    Get.to(()=> ChangeProfileField(
                      title: lang.translate('change_phone'),
                      successMessage: lang.translate('change_phone_msg'),
                      fields: [
                        FieldConfig(
                          label: 'phoneNumner',
                          fieldName: 'PhoneNumber',
                          fieldType: FieldType.text,
                          textController: TextEditingController(text: ""),
                        ),
                      ],
                      onUpdate: (data) async {
                        await controller.updateSingleField(data);
                      },
                    ));
                  },
                  title: lang.translate('phoneNo'),
                  value: controller.user.value.phoneNumber)),
              Obx(
                    () =>  TProfileMenu(onPressed: () {
                  Get.to(()=> ChangeProfileField(
                    title: lang.translate('change_gender'),
                    successMessage: lang.translate('change_gender_msg'),
                    fields: [
                      FieldConfig(
                        label: 'gender',
                        fieldName: 'Gender',
                        fieldType: FieldType.text,
                        textController: TextEditingController(text: ""),
                      ),
                    ],
                    onUpdate: (data) async {
                      await controller.updateSingleField(data);
                    },
                  ));
                },
                    title: lang.translate('gender'),
                    value: controller.user.value.gender),
              ),
              Obx(
                    () => TProfileMenu(
                    onPressed: () {
                      Get.to(()=> ChangeProfileField(
                        title: lang.translate('change_dob'),
                        successMessage: lang.translate('change_dob_msg'),
                        fields: [
                          FieldConfig(
                            label: 'dateOfBirth',
                            fieldName: 'DateOfBirth',
                            fieldType: FieldType.date,
                          ),
                        ],
                        onUpdate: (data) async {
                          await controller.updateSingleField(data);
                        },
                      ));
                    },
                    title: lang.translate('date_of_birth'),
                    value: DFormatter.FormattedDate1(controller.user.value.dateOfBirth)),
              ),
              const Divider(),
              const SizedBox(height: DSize.spaceBtwItem),
              Center(
                  child: TextButton(
                onPressed: () => controller.deleteAccountWarningPopup(),
                child:  Text(
                  lang.translate('delete_account'),
                  style: TextStyle(color: Colors.red),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
