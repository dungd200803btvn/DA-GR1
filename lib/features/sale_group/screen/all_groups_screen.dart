import 'package:app_my_app/features/sale_group/controller/sale_group_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/loaders/animation_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation_menu.dart';
import '../../../utils/constants/image_strings.dart';
import '../../personalization/screens/setting/setting.dart';
import '../widget/sale_group_card.dart';
import 'create_group_screen.dart';
import 'group_request_screen.dart';

class AllGroupsScreen  extends StatelessWidget {
  const AllGroupsScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =  SaleGroupController.instance;
    final lang = AppLocalizations.of(context);
    final emptyWidget = TAnimationLoaderWidget(
        text: lang.translate('group_empty'),
        animation: TImages.emptyAnimation,
        showAction: true,
        actionText: lang.translate('fill_cart'),
        onActionPressed: (){
          Get.offAll(const NavigationMenu());
        }
    );
    return  Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(lang.translate('sale_group'),style: Theme.of(context).textTheme.headlineSmall),
        leadingOnPressed: ()=> Get.to(const SettingScreen()),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'group_requests') {
                Get.to(() => const GroupRequestScreen());
              } else if (value == 'add_group') {
                Get.to(() => const CreateSaleGroupScreen());
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'group_requests',
                child: Text(lang.translate('group_request')),
              ),
              PopupMenuItem<String>(
                value: 'add_group',
                child: Text(lang.translate('create_groups')),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body:  Obx(
            (){
              if (controller.groups.isEmpty) {
                return emptyWidget;
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.groups.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final group = controller.groups[index];
                  return GroupCard(group: group);
                },
              );
            }
      ),
    );
  }
}
