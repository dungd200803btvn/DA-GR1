import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/data/repositories/authentication/authentication_repository.dart';
import 'package:my_app/data/repositories/user/user_repository.dart';
import 'package:my_app/features/authentication/models/user_model.dart';
import 'package:my_app/features/authentication/screens/login/login.dart';
import 'package:my_app/features/personalization/screens/profile/widgets/re_auth_login_form.dart';
import 'package:my_app/utils/constants/image_strings.dart';
import 'package:my_app/utils/constants/sizes.dart';
import 'package:my_app/utils/popups/full_screen_loader.dart';
import 'package:my_app/utils/popups/loader.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/helper/network_manager.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();
  final profileLoading = false.obs;
  final userRepository = UserRepository.instance;
  Rx<UserModel> user = UserModel.empty().obs;
  final hidePassword = false.obs;
  final imageUploading = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();
  late AppLocalizations lang;
  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }
    @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }
  //fetch user record
  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final user1 = await userRepository.fetchUserDetails();
      user.value = user1;
      if (kDebugMode) {
        print("Gia tri cua user sau khi update: ${user.value.toString()}");
      }
      profileLoading.value = false;
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi xảy ra: ${e.toString()}");
      }
      user.value = UserModel.empty();
    } finally {
      profileLoading.value = false;
    }
  }

  //save user record from any registration provider
  Future<void> saveUserRecord(UserCredential? userCredential) async {
    try {
      await fetchUserRecord();
      if(user.value.id.isEmpty){
        if (userCredential != null) {
          //conver name to first and last name
          final nameParts =
          UserModel.nameParts(userCredential.user!.displayName ?? "");
          final userName =
          UserModel.generateUsername(userCredential.user!.displayName ?? "");
          //Map Data
          final user = UserModel(
              userCredential.user!.uid,
              nameParts[0],
              nameParts.length > 1 ? nameParts.sublist(1).join(' ') : " ",
              userName,
              userCredential.user!.email ?? " ",
              userCredential.user!.phoneNumber ?? " ",
              userCredential.user!.photoURL ?? " ");
          //save data
          await userRepository.saveUserRecord(user);
        }
      }

    } catch (e) {
      TLoader.warningSnackbar(
          title: 'Data not saved',
          message:
              'Something went wrong while saving your information.You can re-save your data in your Profile');
    }
  }

  // Lấy thông tin chi tiết của user hiện tại bằng userId
  Future<UserModel> fetchCurrentUserDetails(String userId) async {
    try {
      final userDetails = await userRepository.fetchUserDetails();
      return userDetails;
    } catch (e) {
      throw 'Failed to fetch user details: $e';
    }
  }

  //delete account warning
  void deleteAccountWarningPopup() {
    Get.defaultDialog(
        contentPadding: const EdgeInsets.all(DSize.md),
        title: lang.translate('delete_account'),
        middleText:
        lang.translate('delete_account_msg'),
        confirm: ElevatedButton(
          onPressed: () async => deleteUserAccount(),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
          child:  Padding(
            padding: EdgeInsets.symmetric(horizontal: DSize.lg),
            child: Text(lang.translate('delete')),
          ),
        ),
        cancel: OutlinedButton(
            onPressed: () => Navigator.of(Get.overlayContext!).pop(),
            child:  Text(lang.translate('cancel'))));
  }
  void deleteUserAccount() async{
    try{
      TFullScreenLoader.openLoadingDialog(lang.translate('process'), TImages.docerAnimation);
      //first re-authenticate user
      final auth = AuthenticationRepository.instance;
      final provider =auth.authUser!.providerData.map((e)=> e.providerId).first;
      if(provider.isNotEmpty){
        //re verify email
        if(provider=='google.com'){
          await auth.signInWithGoole();
          await auth.deleteAccount();
          TFullScreenLoader.stopLoading();
          Get.offAll(const LoginScreen());
        }else if(provider == 'password'){
          TFullScreenLoader.stopLoading();
          Get.to(()=> const ReAuthLoginForm());
        }
      }
    }catch(e){
      TFullScreenLoader.stopLoading();
      TLoader.warningSnackbar(title: lang.translate('snap'),message: e.toString());
    }
  }

  Future<void> reAuthenticateEmailAndPasswordUser() async{
    try{
      TFullScreenLoader.openLoadingDialog(lang.translate('process'), TImages.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      if (!reAuthFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }
      await AuthenticationRepository.instance.reAuthenticateWithEmailAndPassword(verifyEmail.text.trim(), verifyPassword.text.trim());
      await AuthenticationRepository.instance.deleteAccount();

      TFullScreenLoader.stopLoading();
      Get.offAll(const LoginScreen());
    }catch(e){
      TFullScreenLoader.stopLoading();
      TLoader.warningSnackbar(title: lang.translate('snap'),message: e.toString());
    }
  }
  uploadUserProfilePicture()async{
    try{
      final image = await ImagePicker().pickImage(source: ImageSource.gallery,imageQuality: 70,maxHeight: 512,maxWidth: 512);
      if(image!=null){
        imageUploading.value =true;
        final imageUrl = await userRepository.uploadImage("Users/Images/Profile", image);
        Map<String,dynamic> json = {'ProfilePicture':imageUrl};
        await userRepository.updateSingleField(json);
        fetchUserRecord();
        user.refresh();
        // user.value.profilePicture  = imageUrl;
        TLoader.successSnackbar(title: 'Congratulation',message: 'Your Profile Image has been updated!');
    }

    }catch(e){
      TLoader.errorSnackbar(title: lang.translate('snap'),message: 'Something went wrong: $e');
    }finally{
      imageUploading.value =false;
    }
  }
  Future<void> updateSingleField( Map<String,dynamic> json) async{
    try{
      await userRepository.updateSingleField(json);
      await fetchUserRecord();
      TLoader.successSnackbar(title: 'Congratulation',message: 'Your Profile Image has been updated!');
    }catch(e){
      TLoader.errorSnackbar(title: lang.translate('snap'),message: 'Something went wrong: $e');
    }

  }


}
