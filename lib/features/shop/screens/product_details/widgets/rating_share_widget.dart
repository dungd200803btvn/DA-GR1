import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lcd_ecommerce_app/features/review/controller/review_controller.dart';
import '../../../../../utils/constants/sizes.dart';
class TRatingAndShare extends StatelessWidget {
  const TRatingAndShare({
    super.key, required this.productId,
  });
final String productId;
  @override
  Widget build(BuildContext context) {
    final controller = WriteReviewScreenController.instance;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Rating
        FutureBuilder<List<dynamic>>(
            future: Future.wait([
              controller.getAverageRatingByProductId(productId),
              controller.fetchTotalReviews(productId)
            ]),
            builder: (context,snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return Row(
                  children: [
                    const Icon(Iconsax.star5, color: Colors.amber, size: 24),
                    const SizedBox(width: DSize.spaceBtwItem / 2),
                    Text.rich(TextSpan(children: [
                      TextSpan(
                        text: '...', // Hiển thị trạng thái loading
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const TextSpan(text: '(...)'),
                    ])),
                  ],
                );
    }
              if (snapshot.hasError) {
                if (kDebugMode) {
                  print('Loi: ${snapshot.error}');
                }
                return Text("Lỗi dữ liệu", style: TextStyle(color: Colors.red));
              }
              final double averageRating = snapshot.data![0] ?? 0.0;
              final int totalReviews = snapshot.data![1] ?? 0;
                  return  Row(
                    children: [
                      const Icon(Iconsax.star5,color: Colors.amber,size: 24),
                      const SizedBox(width: DSize.spaceBtwItem/2),
                      Text.rich(TextSpan(
                          children: [
                            TextSpan(text: averageRating.toStringAsFixed(1),style: Theme.of(context).textTheme.bodyLarge),
                            TextSpan(text: '($totalReviews)'),
                          ]
                      ))
                    ],
                  );
            }),
        //Share Button
        IconButton(onPressed: (){}, icon: const Icon(Icons.share,size: DSize.iconMd)),
      ],
    );
  }
}