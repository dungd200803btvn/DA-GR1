import 'package:app_my_app/features/shop/screens/product_reviews/widgets/profile.dart';
import 'package:app_my_app/utils/formatter/formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../l10n/app_localizations.dart';
import '../../sale_group/model/friend_request_model.dart';
import '../controllers/friend_requests_controller.dart';

class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FriendRequestsController controller =FriendRequestsController.instance;
    var lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('friend_request'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.requests.isEmpty) {
          return Center(child: Text(lang.translate('no_friend_request'),));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.requests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final FriendRequestModel request = controller.requests[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade300), // viền nhẹ
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thông tin người gửi
                    UserInfo(userId: request.fromUserId),
                    const SizedBox(height: 12),

                    // Nội dung lời mời
                    Text(
                      request.message,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 10),

                    // Thời gian gửi
                    Text(
                      "${lang.translate('send_at')}: ${DFormatter.FormattedDate(request.sentAt)}",
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),

                    // Hai nút hành động
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await controller.updateRequestStatus(
                                request.id,
                                'accepted',
                                request.fromUserId,
                                context,
                              );
                            },
                            icon: const Icon(Icons.check, size: 18),
                            label: Text(
                              lang.translate('accept_request'),
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await controller.updateRequestStatus(
                                request.id,
                                'rejected',
                                request.fromUserId,
                                context,
                              );
                            },
                            icon: const Icon(Icons.close, size: 18),
                            label: Text(
                              lang.translate('reject_request'),
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
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