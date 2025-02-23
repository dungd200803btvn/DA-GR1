import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/features/notification/controller/notification_controller.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';

// class NotificationIcon extends StatelessWidget {
//   const NotificationIcon({super.key, });
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = NotificationController.instance;
//     return Obx(() {
//       return Stack(
//         clipBehavior: Clip.none,
//         children: [
//           const Icon(Icons.notifications),
//           if (controller.notificationCount.value > 0)
//             Positioned(
//               right: -4,
//               top: -4,
//               child: Container(
//                 padding: const EdgeInsets.all(2),
//                 decoration: BoxDecoration(
//                   color: Colors.red,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 constraints: const BoxConstraints(
//                   minWidth: 16,
//                   minHeight: 16,
//                 ),
//                 child: Text(
//                   '${controller.notificationCount.value}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//         ],
//       );
//     });
//   }
// }

class NotificationIcon extends StatefulWidget {
  const NotificationIcon({super.key});

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  Future<int> _fetchNotificationCount() async {
    String? userId = AuthenticationRepository.instance.authUser?.uid;
    if (userId == null) return 0; // Nếu user chưa đăng nhập, trả về 0 thông báo

    final snapshot = await FirebaseFirestore.instance
        .collection('User')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();

    return snapshot.docs.length; // Trả về số lượng thông báo chưa đọc
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _fetchNotificationCount(),
      builder: (context, snapshot) {
        int count = snapshot.data ?? 0; // Nếu chưa có dữ liệu, mặc định là 0

        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications),
            if (count > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

