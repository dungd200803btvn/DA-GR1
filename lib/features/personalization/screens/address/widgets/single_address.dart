import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:app_my_app/features/personalization/controllers/address_controller.dart';
import 'package:app_my_app/utils/constants/colors.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
import 'package:app_my_app/utils/helper/helper_function.dart';

import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../models/address_model.dart';
class TSingleAddress extends StatelessWidget {
  const TSingleAddress({super.key, required  this.address, required this.onTap,
    });
    final AddressModel address;
    final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final controller = AddressController.instance;
    return Obx(
      (){
        final selectedAddressId = controller.selectedAddress.value.id;
        final selectedAddress = selectedAddressId == address.id;
        return  InkWell(
          onTap: onTap,
          child: TRoundedContainer(
            padding: const EdgeInsets.all(DSize.md),
            width: double.infinity,
            showBorder: true,
            backgroundColor: selectedAddress? DColor.primary.withOpacity(0.5):Colors.transparent,
            borderColor: selectedAddress? Colors.transparent: dark? DColor.darkerGrey:DColor.grey,
            margin: const EdgeInsets.only(bottom: DSize.spaceBtwItem),
            child: Stack(
              children: [
                Positioned(
                  right: 5,
                  top: 0,
                  child: Icon(
                    selectedAddress? Iconsax.tick_circle5: null,
                    color: selectedAddress? dark? DColor.light:DColor.dark.withOpacity(0.2):null,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,),
                    const SizedBox(height: DSize.sm/2,),
                    Text(address.formattedPhoneNo,maxLines: 1,overflow: TextOverflow.ellipsis,),
                    const SizedBox(height: DSize.sm/2,),
                    Text(address.toString(),softWrap: true,)
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }
}
