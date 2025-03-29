import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcd_ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:lcd_ecommerce_app/data/repositories/authentication/authentication_repository.dart';
import 'package:lcd_ecommerce_app/features/personalization/controllers/address_controller.dart';
import 'package:lcd_ecommerce_app/utils/constants/colors.dart';
import 'package:lcd_ecommerce_app/utils/constants/sizes.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/helper/helper_function.dart';
class TBillingAddressSection extends StatelessWidget {
  const TBillingAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final addressController = AddressController.instance;
    final lang = AppLocalizations.of(context);
    return Obx(
      ()=> Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TSectionHeading(title: lang.translate('shipping_address'),buttonTitle: lang.translate('change'),onPressed: ()=> addressController.selectNewAddressPopup(context),),
          addressController.selectedAddress.value.id.isNotEmpty?
          Obx(
          ()=> Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(addressController.selectedAddress.value.name,style: Theme.of(context).textTheme.bodyLarge,),
                const SizedBox(height: DSize.spaceBtwItem/2,),
                Row(
                  children: [
                    const Icon(Icons.phone,color: DColor.grey,size: 16,),
                    const SizedBox(width: DSize.spaceBtwItem,),
                    Text(addressController.selectedAddress.value.formattedPhoneNo,style: Theme.of(context).textTheme.bodyMedium,)
                  ],
                ),
                const SizedBox(height: DSize.spaceBtwItem/2,),
                Row(
                  children: [
                    const Icon(Icons.location_history,color: DColor.grey,size: 16,),
                    const SizedBox(width: DSize.spaceBtwItem,),
                    Expanded(child: Text(addressController.selectedAddress.value.toString(),style: Theme.of(context).textTheme.bodyMedium,softWrap: true,)),

                  ],
                ),
              ],
            ),
          ) : Text(lang.translate('select_address'),style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
