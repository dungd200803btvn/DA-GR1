import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class EventLogger {
  // Singleton instance
  static final EventLogger _instance = EventLogger._internal();
  factory EventLogger() => _instance;
  EventLogger._internal();
  String? _userId;
  String? _sessionId;
  // Khai báo các instance của Firestore và Firebase Analytics
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  void initialize({required String userId,required String sessionId}){
    _userId = userId;
    _sessionId =sessionId;
  }
  /// Ghi log sự kiện vào Firestore và Firebase Analytics
  Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? additionalData,
  }) async {
    if(_userId ==null|| _sessionId==null){
      throw Exception('User ID hoặc Session ID chưa được khởi tạo.');
    }
    // Ghi log vào Firestore (dùng cho quá trình train ML)
    await _firestore.collection('user_events').add({
      'user_id': _userId,
      'event': eventName,
      'session_id': _sessionId,
      'timestamp': FieldValue.serverTimestamp(),
      ...?additionalData,
    });

    // Ghi log vào Firebase Analytics (dùng cho báo cáo, DebugView, phân tích thời gian thực)
    await _analytics.logEvent(
      name: eventName,
      parameters: {
        'user_id': _userId,
        'session_id': _sessionId,
        ...?additionalData,
      },
    );
  }

  /// Đặt user property cho Firebase Analytics
  Future<void> setUserProperty({
    required String propertyName,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: propertyName, value: value);
    // Nếu cần, bạn cũng có thể lưu thông tin này vào Firestore trong một collection riêng.
  }
}
