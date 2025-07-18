import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;       // Mã định danh của đánh giá
  final String productId;      // Mã sản phẩm được đánh giá
  final String userId;         // Mã người dùng đánh giá (có thể dùng rỗng hoặc null nếu đăng ẩn danh)
  final double rating;            // Số sao đánh giá (1-5)
  final String comment;        // Nội dung đánh giá (tối đa 300 ký tự)
  final List<String> imageUrls; // Danh sách URL của các hình ảnh được upload
  final List<String> videoUrls; // Danh sách URL của các video được upload
  final bool isAnonymous;      // Cờ đánh dấu đăng ẩn danh hay không
  final DateTime createdAt;    // Thời gian tạo đánh giá

  ReviewModel({
    required this.reviewId,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.imageUrls,
    required this.videoUrls,
    required this.isAnonymous,
    required this.createdAt,
  });
  
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: json['reviewId'] as String,
      productId: json['productId'] as String,
      userId: json['userId'] as String,
      rating: json['rating'] as double,
      comment: json['comment'] as String,
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      videoUrls: json['videoUrls'] != null
          ? List<String>.from(json['videoUrls'])
          : [],
      isAnonymous: json['isAnonymous'] as bool,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  // Chuyển đổi từ model sang JSON để lưu lên Firestore
  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'productId': productId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
      'isAnonymous': isAnonymous,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
