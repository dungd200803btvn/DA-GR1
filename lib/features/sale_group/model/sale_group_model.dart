import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/enum/enum.dart';

class SaleGroupModel {
  final String id;
  final String name;
  final String? shopId;
  final String? brandId;
  final String? categoryId;
  final int targetParticipants;
  final int currentParticipants;
  final double discount;
  final List<String> participants;
  final String creatorId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final SaleGroupStatus status;
  final String selectedObjectName;

  SaleGroupModel({
    required this.id,
     this.name = "",
    this.shopId,
    this.brandId,
    this.categoryId,
    required this.targetParticipants,
    required this.currentParticipants,
    required this.discount,
    required this.participants,
    required this.creatorId,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    required this.selectedObjectName
  });

  // Chuyển đối tượng thành Map để lưu lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name':name,
      'shopId': shopId,
      'brandId': brandId,
      'categoryId': categoryId,
      'targetParticipants': targetParticipants,
      'currentParticipants': currentParticipants,
      'discount': discount,
      'participants': participants,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'status':  status.toString().split('.').last,
      'selectedObjectName': selectedObjectName
    };
  }

  // Tạo đối tượng từ Map (khi đọc từ Firebase)
  factory SaleGroupModel.fromMap(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map<String, dynamic>;

    DateTime parseTimestamp(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is Timestamp) {
        return value.toDate();
      } else {
        throw Exception("Invalid timestamp type: $value");
      }
    }
    // Chuyển đổi string về enum
    SaleGroupStatus parseStatus(String statusStr) {
      return SaleGroupStatus.values.firstWhere(
              (e) => e.toString().split('.').last == statusStr,
          orElse: () => SaleGroupStatus.pending);
    }

    return SaleGroupModel(
      id: map['id'] as String,
      name: map['name']!=null? map['name'] as String:"anh em cây khế",
      shopId: map['shopId'] as String?,
      brandId: map['brandId'] as String?,
      categoryId: map['categoryId'] as String?,
      targetParticipants: map['targetParticipants'] as int,
      currentParticipants: map['currentParticipants'] as int,
      discount: (map['discount'] as num).toDouble(),
      participants: List<String>.from(map['participants'] as List),
      creatorId: map['creatorId'] as String,
      createdAt: parseTimestamp(map['createdAt']),
      expiresAt: parseTimestamp(map['expiresAt']),
      status: parseStatus(map['status'] as String),
      selectedObjectName: map['selectedObjectName'] as String,
    );
  }
}
