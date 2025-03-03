import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/features/personalization/controllers/update_name_controller.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/constants/text_string.dart';
import 'package:t_store/utils/validators/validation.dart';

import '../../../../../l10n/app_localizations.dart';
class ChangeName extends StatelessWidget {
  const ChangeName({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UpdateNameController.instance;
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: TAppBar(showBackArrow: true,title: Text(lang.translate('change_name'),style: Theme.of(context).textTheme.headlineSmall,)),
      body: Padding(
        padding: const EdgeInsets.all(DSize.defaultspace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Heading
            Text(lang.translate('change_name_msg'),style: Theme.of(context).textTheme.labelMedium,),
            const SizedBox(height: DSize.spaceBtwSection,),
            //Textfiela and button
            Form(key: controller.updateUsernameFormKey,
                child: Column(
              children: [
                TextFormField(
                  controller: controller.firstName,
                  validator: (value)=> DValidator.validateEmptyText('Firstname', value),
                  expands: false,
                  decoration:  InputDecoration(labelText: lang.translate('firstName'),prefixIcon: Icon(Iconsax.user)),

                ),
                const SizedBox(height: DSize.spaceBtwInputFielRadius,),
                TextFormField(
                  controller: controller.lastName,
                  validator: (value)=> DValidator.validateEmptyText('Lastname', value),
                  expands: false,
                  decoration: InputDecoration(labelText: lang.translate('lastName'),prefixIcon: Icon(Iconsax.user)),

                ),
              ],
            )),
            const SizedBox(height: DSize.spaceBtwSection,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ()=> controller.updateUserName(),
                child:  Text(lang.translate('save')),
              ),
            )

          ],
        ),
      ),
    );
  }
}
