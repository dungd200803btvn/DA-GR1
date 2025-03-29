import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_my_app/common/widgets/texts/section_heading.dart';
import 'package:app_my_app/data/repositories/address/address_repository.dart';
import 'package:app_my_app/features/personalization/screens/address/add_new_address.dart';
import 'package:app_my_app/features/personalization/screens/address/address.dart';
import 'package:app_my_app/features/personalization/screens/address/widgets/single_address.dart';
import 'package:app_my_app/l10n/app_localizations.dart';
import 'package:app_my_app/utils/constants/image_strings.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
import 'package:app_my_app/utils/helper/cloud_helper_functions.dart';
import 'package:app_my_app/utils/popups/full_screen_loader.dart';
import 'package:app_my_app/utils/popups/loader.dart';
import '../../../utils/helper/network_manager.dart';
import '../models/address_model.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();
  final name = TextEditingController();
  final phoneNumber = TextEditingController();
  final street = TextEditingController();
  String selectedCity = "";
  String selectedDistrict = "";
  String selectedWard = "";
  GlobalKey<FormState> addressFormkey = GlobalKey<FormState>();
  final addressRepository = Get.put(AddressRepository());
  final Rx<AddressModel> selectedAddress = AddressModel.empty().obs;
  RxBool refreshData = true.obs;
  late AppLocalizations lang;

  @override
  void onInit() {
    fetchAndSetSelectedAddress();
    super.onInit();
  }
  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }

  void fetchAndSetSelectedAddress() async {
    try {
      final address = await addressRepository.fetchSelectedAddress();
      selectedAddress.value = address;
      refreshData.value = !refreshData.value; // Trigger UI update
    } catch (e) {
      TLoader.errorSnackbar(
        title: lang.translate('error'),
        message: e.toString(),
      );
    }
  }
  //fetch all user specific addresses
  Future<List<AddressModel>> getAllUserAddresses() async {
    try {
      final addresses = await addressRepository.fetchUserAddress();
      selectedAddress.value = addresses.firstWhere(
          (element) => element.selectedAddress,
          orElse: () => AddressModel.empty());
      return addresses;
    } catch (e) {
      TLoader.errorSnackbar(title: lang.translate('address_not_found'), message: e.toString());
      return [];
    }
  }

  Future selectAddress(AddressModel newSelectedAddress) async {
    try {
      Get.defaultDialog(
        title: "",
        onWillPop: () async {
          return false;
        },
        barrierDismissible: false,
        backgroundColor: Colors.transparent,
        content:  Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              lang.translate('update_select_address'),
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
      if (selectedAddress.value.id.isNotEmpty) {
        await addressRepository.updateSelectedField(
            selectedAddress.value.id, false);
      }
      newSelectedAddress.selectedAddress = true;
      selectedAddress.value = newSelectedAddress;
      await addressRepository.updateSelectedField(
          selectedAddress.value.id, true);
      Get.back();
    } catch (e) {
      TLoader.errorSnackbar(title: lang.translate('err_select_address'), message: e.toString());
    }
  }

  Future addNewAddresses() async {
    try {
      TFullScreenLoader.openLoadingDialog(
          lang.translate('add_address'), TImages.docerAnimation);
      //Check internet connect
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      if (!addressFormkey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }
      //save address data
      final address = AddressModel(
          id: " ",
          name: name.text.trim(),
          phoneNumber: phoneNumber.text.trim(),
          street: street.text.trim(),
          city: selectedCity,
          district: selectedDistrict,
          commune: selectedWard,
          country: "Việt Nam",
          dateTime: DateTime.now(),
          selectedAddress: false);
      final id = await addressRepository.addAddress(address);
      address.id = id;
      //remove loader
      TFullScreenLoader.stopLoading();
      TLoader.successSnackbar(
          title: lang.translate('congratulations'),
          message: lang.translate('add_address_success_msg'));
      //refresh data
      refreshData.value = !refreshData.value;
      //reset field
      resetFormField();
      //redirect
      Get.to(() => const UserAddressScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoader.errorSnackbar(title: lang.translate('address_not_found'), message: e.toString());
    }
  }

  Future<dynamic> selectNewAddressPopup(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.all(DSize.lg),
        child: SingleChildScrollView( // Sử dụng SingleChildScrollView để bọc Column
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TSectionHeading(title: lang.translate('select_address'), showActionButton: false,),
              FutureBuilder(
                future: getAllUserAddresses(),
                builder: (_, snapshot) {
                  final response =
                  TCloudHelperFunctions.checkMultiRecordState(
                      snapshot: snapshot);
                  if (response != null) return response;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Ngăn ListView tự cuộn
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) => TSingleAddress(
                      address: snapshot.data![index],
                      onTap: () async {
                        await selectAddress(snapshot.data![index]);
                        Get.back();
                      },
                    ),

                  );
                },
              ),
              const SizedBox(height: DSize.defaultspace * 2,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => AddNewAddressScreen()),
                  child: Text(lang.translate('add_address')),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void resetFormField() {
    name.clear();
    phoneNumber.clear();
    street.clear();
    selectedCity   ="";
    selectedDistrict = "";
    selectedWard = "";
    addressFormkey.currentState?.reset();
  }

  Future<void> deleteAddress(String userId, String addressId) async{
    addressRepository.deleteAddress(userId, addressId);
  }
  Future<void> updateAddress(String userId, AddressModel updatedAddress) async{
    addressRepository.updateAddress(userId, updatedAddress);
  }

}
