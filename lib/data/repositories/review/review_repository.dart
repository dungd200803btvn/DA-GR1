import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/review/model/review_model.dart';

class ReviewRepository {
  static ReviewRepository get instance => ReviewRepository();
  final _db = FirebaseFirestore.instance;

  Future<void> saveReview(ReviewModel review) async {
    DocumentReference documentReference =  await _db
        .collection('Review')
        .add(review.toJson());
    await documentReference.update({
      'reviewId':documentReference.id
    });
  }

  /// 1. Lấy tổng số review của sản phẩm dựa vào productId
  Future<int> getTotalReviewsByProductId(String productId) async {
    QuerySnapshot querySnapshot = await _db
        .collection('Review')
        .where('productId', isEqualTo: productId)
        .get();

    return querySnapshot.size; // Trả về số lượng document (review) trong collection
  }

  /// 2. Tính giá trị trung bình của rating dựa vào productId
  Future<double> getAverageRatingByProductId(String productId) async {
    QuerySnapshot querySnapshot = await _db
        .collection('Review')
        .where('productId', isEqualTo: productId)
        .get();

    if (querySnapshot.docs.isEmpty) return 0.0; // Nếu không có review nào thì trả về 0.0

    double totalRating = 0;
    for (var doc in querySnapshot.docs) {
      totalRating += (doc['rating'] as num).toDouble();
    }
    return totalRating / querySnapshot.size;
  }

  /// 3. Lấy danh sách các review dựa vào productId, trả về List<ReviewModel>
  Future<List<ReviewModel>> getReviewsByProductId(String productId) async {
    QuerySnapshot querySnapshot = await _db
        .collection('Review')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true) // Lấy mới nhất trước
        .get();

    return querySnapshot.docs
        .map((doc) => ReviewModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
