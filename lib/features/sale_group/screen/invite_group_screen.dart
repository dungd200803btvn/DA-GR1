import 'package:app_my_app/features/setting/controllers/friend_list_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../l10n/app_localizations.dart';
import '../../shop/screens/product_reviews/widgets/profile.dart';
import '../controller/invite_group_controller.dart';
import '../model/sale_group_model.dart';

class InviteFriendToGroupScreen extends StatelessWidget {
  final SaleGroupModel group;
  const InviteFriendToGroupScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final controller = InviteGroupController.instance;
    final friendListController = FriendListController.instance;
    final lang = AppLocalizations.of(context);

    return Scaffold(
      appBar: TAppBar(
        title: Text(lang.translate('invite_group')),
        showBackArrow: true,
      ),
      body: Obx(() {
        if (friendListController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (friendListController.friends.isEmpty) {
          return Center(child: Text(lang.translate('no_friend')));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: friendListController.friends
              .where((friend) => !group.participants.contains(friend.friendId))
              .length,
          itemBuilder: (context, index) {
            final availableFriends = friendListController.friends
                .where((friend) => !group.participants.contains(friend.friendId))
                .toList();
            final friend = availableFriends[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // UserInfo hiển thị avatar + tên
                    UserInfo(userId: friend.friendId),

                    const SizedBox(height: 12),

                    // Căn button về phía bên phải
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            await controller.sendGroupInvitation(friend.friendId, context, group);
                          },
                          icon: const Icon(Icons.person_add_alt_1, size: 18),
                          label: Text(lang.translate('invite_group')),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
