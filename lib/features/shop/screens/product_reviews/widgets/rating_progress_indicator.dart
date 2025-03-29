import 'package:flutter/material.dart';
import 'package:my_app/features/review/controller/review_controller.dart';
import 'package:my_app/features/shop/screens/product_reviews/widgets/progress_indicator_and_rating.dart';
class TOverallProductRating extends StatelessWidget {
  const TOverallProductRating({
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
    final controller  = WriteReviewScreenController.instance;
    return Row(
      children: [
        FutureBuilder<double>(future: controller.getAverageRatingByProductId(productId,
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
            return const Text("?",
                style: TextStyle(
                    color: Colors.red)); // Nếu lỗi, hiển thị "?"
          }
          double average = snapshot.data?? 0.0;
          return  Expanded(flex:3,child:  Text('${average.toStringAsFixed(1)}',style: Theme.of(context).textTheme.displayLarge,));
        },),

        const Expanded(
          flex:7,
          child: Column(
            children: [
              TRatingProgressIndicator(text: '5', value: 1.0,),
              TRatingProgressIndicator(text: '4', value: 0.8,),
              TRatingProgressIndicator(text: '3', value: 0.6,),
              TRatingProgressIndicator(text: '2', value: 0.4,),
              TRatingProgressIndicator(text: '1', value: 0.2,),
            ],
          ),
        )
      ],
    );
  }
}
