const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

/**
 * Function tự động gửi push notification mỗi khi có thông báo mới được thêm vào
 * Firestore tại đường dẫn: User/{userId}/notifications/{notificationId}
 */
exports.sendNotification = functions.firestore
    .document("User/{userId}/notifications/{notificationId}")
    .onCreate(async (snapshot, context) => {
      const notificationData = snapshot.data();
      const {userId} = context.params;

      // Lấy FCM token của người dùng từ document user
      const userDoc = await admin
          .firestore()
          .collection("User")
          .doc(userId)
          .get();
      if (!userDoc.exists) {
        console.log(`Không tìm thấy thông tin user ${userId}`);
        return null;
      }
      const userData = userDoc.data();
      const fcmToken = userData.FcmToken;
      if (!fcmToken) {
        console.log(`User ${userId} không có FCM token`);
        return null;
      }

      // Tạo payload cho FCM
      const payload = {
        notification: {
          title: notificationData.title,
          body: notificationData.message,
        },
        data: {
          notificationId: notificationData.id,
          type: notificationData.type,
          // Thêm các trường dữ liệu khác nếu cần
        },
      };

      try {
        // Gửi push notification tới token của người dùng
        const response = await admin.messaging().sendToDevice(
            fcmToken,
            payload);
        console.log(`Push notification gửi thành công đến user ${userId}:`
            , response);
      } catch (error) {
        console.error("Lỗi khi gửi push notification:", error);
      }

      return null;
    });
