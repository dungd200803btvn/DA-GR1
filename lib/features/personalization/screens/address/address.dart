import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lcd_ecommerce_app/features/personalization/controllers/address_controller.dart';
import 'package:lcd_ecommerce_app/features/personalization/screens/address/widgets/single_address.dart';
import 'package:lcd_ecommerce_app/features/personalization/screens/setting/setting.dart';
import 'package:lcd_ecommerce_app/utils/constants/sizes.dart';
import 'package:lcd_ecommerce_app/utils/helper/cloud_helper_functions.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/constants/colors.dart';
import 'add_new_address.dart';
import 'edit_address.dart';
class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());
    final lang = AppLocalizations.of(context);
    return  Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: DColor.primary,
        onPressed: ()=> Get.to(()=> const AddNewAddressScreen()),
        child: const Icon(Iconsax.add,color: DColor.white,),
      ),
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(lang.translate('addresses'),style: Theme.of(context).textTheme.headlineSmall, ),
        leadingOnPressed: ()=> Get.to(const SettingScreen()),
      ),
      body:  SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          child: Obx(
              ()=> FutureBuilder(
                key: Key(controller.refreshData.value.toString()),
                future: controller.getAllUserAddresses(),
                builder: (context,snapshot){
              final response = TCloudHelperFunctions.checkMultiRecordState(snapshot: snapshot);
              if(response!=null) return response;
              final addresses = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                  itemCount: addresses.length,
                  itemBuilder: (_,index)
                  => TSingleAddress(
                    address: addresses[index],
                    onTap: () =>Get.to(EditAddressScreen(address: addresses[index],)),));
            }),
          ),
        ),
      ),
    );
  }
}
