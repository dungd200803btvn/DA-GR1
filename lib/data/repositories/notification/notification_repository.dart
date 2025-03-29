import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_my_app/features/notification/model/notification_model.dart';

class NotificationRepository {
  static NotificationRepository get instance => NotificationRepository();
  final _db = FirebaseFirestore.instance;
  // Fetch all notifications
  Future<List<NotificationModel>> fetchAllNotifications(String userId) async {
    try {
      final result = await _db.collection('User').doc(userId).collection('notifications').orderBy('timestamp', descending: true).get();
      return result.docs.map((doc) => NotificationModel.fromMap(doc)).toList();
    } catch (e) {
      throw 'Error fetching notifications: $e';
    }
  }

  Future<void> markNotificationAsRead(String userId, String notificaitonId) async {
    final querySnapshot = await _db
        .collection('User')
        .doc(userId)
        .collection('notifications')
        .where('id', isEqualTo: notificaitonId)
        .get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.update({
        'read': true,
         });
    }
  }

}
