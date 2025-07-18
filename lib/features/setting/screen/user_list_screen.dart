import 'package:app_my_app/features/setting/controllers/user_list_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../l10n/app_localizations.dart';
import '../../authentication/models/user_model.dart';
import '../../shop/screens/product_reviews/widgets/profile.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserListController.instance;
    final lang = AppLocalizations.of(context);

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('user_list'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // 🔍 Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: controller.filterUsers,
                decoration: InputDecoration(
                  hintText: lang.translate('search'),
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // 🔢 Tổng số người
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.blue.shade50,
              child: Obx(() => Text(
                "${lang.translate('add_friend')} (${controller.users.length})",
                style: Theme.of(context).textTheme.titleMedium,
              )),
            ),

            // 👥 Danh sách người dùng
            Expanded(
              child: Obx(() => ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UserInfo(userId: user.id),
                                const SizedBox(height: 6),
                                Text(
                                  user.email,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () async{
                            await controller.sendFriendInvitation(user, context);
                            },
                            icon: const Icon(Icons.person_add_alt_1,
                                size: 18),
                            label: Text(lang.translate('add_friend')),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )),
            ),
          ],
        );
      }),
    );
  }
}
