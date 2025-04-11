enum ProductType {variable,single}
enum TextSizes{small,medium,large}
enum OrderStatus{processing,shipped,delivered}
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
