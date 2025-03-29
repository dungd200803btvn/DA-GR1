import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lcd_ecommerce_app/features/review/controller/review_controller.dart';

import '../../../../utils/constants/colors.dart';
class TRatingBarIndicator extends StatelessWidget {
  const TRatingBarIndicator({
    super.key, required this.productId,
    this.filterRating,
    this.filterWithMedia = false,
    this.sortByTime = true,
  });
final String productId;
  final int? filterRating;
  final bool filterWithMedia;
  final bool sortByTime;
  @override
  Widget build(BuildContext context) {
    final controller = WriteReviewScreenController.instance;
    return  FutureBuilder<double>(future: controller.getAverageRatingByProductId(  productId,
      filterRating: filterRating,
      filterWithMedia: filterWithMedia,
      sortByTime: sortByTime,),
        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ); // Hiển thị loading nhỏ
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Text("?", style: TextStyle(color: Colors.red)); // Nếu lỗi, hiển thị "?"
          }
          double rating = snapshot.data ?? 0.0;
          return RatingBarIndicator(
            rating: rating,
            itemSize: 20,
            itemCount: 5,
            unratedColor: DColor.grey,
            itemBuilder: (_, __) => const Icon(Iconsax.star1, color: Colors.amber),
          );
        },
    );
        }
  }
