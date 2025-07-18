import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';

class NotificationIcon extends StatefulWidget {
  const NotificationIcon({super.key});
  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  Stream<int>  _notificationCountStream()  {
    String? userId = AuthenticationRepository.instance.authUser?.uid;
    if (userId == null) return Stream.value(0); // Nếu user chưa đăng nhập, trả về 0 thông báo

    return FirebaseFirestore.instance
        .collection('User')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _notificationCountStream(),
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
