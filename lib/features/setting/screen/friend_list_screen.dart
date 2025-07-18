import 'package:app_my_app/features/setting/screen/user_list_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../l10n/app_localizations.dart';
import '../../shop/screens/product_reviews/widgets/profile.dart';
import '../controllers/friend_list_controller.dart';
import 'friend_requests_screen.dart';

class FriendListScreen extends StatelessWidget {
  const FriendListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = FriendListController.instance;
    var lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('friend_list'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'friend_requests') {
                Get.to(() => const FriendRequestsScreen());
              } else if (value == 'user_list') {
                Get.to(() => const UserListScreen());
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'friend_requests',
                child: Text(lang.translate('friend_request')),
              ),
              PopupMenuItem<String>(
                value: 'user_list',
                child: Text(lang.translate('user_list')),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.friends.isEmpty) {
          return Center(child: Text(lang.translate('no_friend'),));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.friends.length,
          itemBuilder: (context, index) {
            final friend = controller.friends[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: UserInfo(userId: friend.friendId), // Hiển thị avatar và tên
              ),
            );
          },
        );
      }),
    );
  }
}
