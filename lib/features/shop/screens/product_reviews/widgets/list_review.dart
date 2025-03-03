import 'package:flutter/material.dart';
import 'package:t_store/l10n/app_localizations.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../review/controller/review_controller.dart';
import '../../../../review/model/review_model.dart';
import 'user_review_card.dart';

class ReviewListWidget extends StatelessWidget {
  final String productId;
  final int? filterRating;
  final bool filterWithMedia;
  final bool sortByTime;
  const ReviewListWidget({super.key,
    required this.productId,
    this.filterRating,
    this.filterWithMedia = false,
    this.sortByTime = true,});

  @override
  Widget build(BuildContext context) {
    final controller = WriteReviewScreenController.instance;
    final lang =AppLocalizations.of(context);
    return FutureBuilder<List<ReviewModel>>(
      future: controller.getReviewsByProductId(
        productId,
        filterRating: filterRating,
        filterHasMedia: filterWithMedia,
        sortByTime: sortByTime,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return  Center(child: Text(lang.translate('err_load_review')));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return  Center(child: Text(lang.translate('no_review')));
        }
        final reviews = snapshot.data!;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => const SizedBox(height: DSize.spaceBtwSection),
          itemBuilder: (context, index) {
            return UserReviewCard(review: reviews[index]);
          },
        );
      },
    );
  }
}
