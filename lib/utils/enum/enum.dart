enum ProductType {variable,single}
enum TextSizes{small,medium,large}
enum OrderStatus{pending, processing,shipped,delivered}
enum PaymentMethods{paypal,googlePay,applePay,visa,masterCard,creditCard,paystack,razorPay,paytm}
enum SaleGroupStatus {
  pending,
  completed,
  expired,
  canceled, // Tuỳ chọn, nếu bạn muốn cho phép hủy nhóm
}
enum FriendStatus { active, blocked }
enum FriendRequestStatus { pending, accepted, rejected }
enum GroupRequestResult {
  alreadyMember,
  accepted,
  rejected,
  error,
  completed
}

// mission_type_enum.dart
enum MissionType {
  writeReview,
  highValueOrder,
  viewProduct,
  quickOrder,
  viewShop,
  viewBrand,
}

extension MissionTypeExtension on MissionType {
  String get name {
    switch (this) {
      case MissionType.writeReview:
        return 'write_review';
      case MissionType.highValueOrder:
        return 'high_value_order';
      case MissionType.viewProduct:
        return 'view_product';
      case MissionType.quickOrder:
        return 'quickOrder';
      case MissionType.viewShop:
        return 'view_shop';
      case MissionType.viewBrand:
        return 'view_brand';
    }
  }

  static MissionType fromString(String value) {
    return MissionType.values.firstWhere(
            (e) => e.name == value,
        orElse: () => MissionType.writeReview);
  }
}
enum MissionDurationType {
  none,           // Không giới hạn thời gian
  daily,          // Trong vòng 24h kể từ lúc bắt đầu
  weekly,         // Trong vòng 7 ngày
  customRange,    // Khoảng thời gian cụ thể do admin đặt
}

enum UserMissionStatus {
  inProgress,
  completed,
  claimed,
  expired, // thêm trạng thái quá hạn nếu cần
}

