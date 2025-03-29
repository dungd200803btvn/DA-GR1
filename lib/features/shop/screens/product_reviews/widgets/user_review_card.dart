import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:my_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:my_app/common/widgets/products/ratings/rating_indicator.dart';
import 'package:my_app/features/review/model/review_model.dart';
import 'package:my_app/features/shop/screens/product_reviews/widgets/user_profile.dart';
import 'package:my_app/features/shop/screens/product_reviews/widgets/video_player.dart';
import 'package:my_app/features/shop/screens/product_reviews/widgets/video_thumbnail.dart';
import 'package:my_app/l10n/app_localizations.dart';
import 'package:my_app/utils/constants/colors.dart';
import 'package:my_app/utils/constants/image_strings.dart';
import 'package:my_app/utils/constants/sizes.dart';
import 'package:my_app/utils/helper/helper_function.dart';

import '../../../../../common/widgets/products/ratings/user_rating_indicator.dart';
import '../../../../review/widget/full_screen_image.dart';
class UserReviewCard extends StatelessWidget {
  const UserReviewCard({super.key, required this.review});
final ReviewModel review;
  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    String locale = Localizations.localeOf(context).languageCode;
    String formattedDate = DateFormat("dd/MM/yyyy HH:mm",locale).format(review.createdAt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Thong tin nguoi dang
        UserProfileInfo(review: review),
        const SizedBox(height: DSize.spaceBtwItem,),
        //So sao va tg review
        Row(
          children: [
             UserRatingBarIndicator(rating: review.rating),
            const SizedBox(width: DSize.spaceBtwItem,),
            Text(formattedDate,style: Theme.of(context).textTheme.bodyMedium,)
          ],
        ),
        const SizedBox(height: DSize.spaceBtwItem,),
         //Noi dung review
         ReadMoreText(review.comment,
        trimLines: 2,
        trimExpandedText: lang.translate('less'),
        trimCollapsedText: lang.translate('show_more'),
        trimMode: TrimMode.Line,
        moreStyle: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: DColor.primary),
        lessStyle: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: DColor.primary),
        ),
        const SizedBox(height: DSize.spaceBtwItem),
        //Danh sach anh va video
        if (review.imageUrls.isNotEmpty || review.videoUrls.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị danh sách ảnh
              if (review.imageUrls.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: review.imageUrls.length,
                    itemBuilder: (context, index) {
                      final imageUrl = review.imageUrls[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageScreen(imageUrl: imageUrl),
                              ),
                            );
                          },
                          child: Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              // Hiển thị danh sách video (ví dụ chỉ hiện thumbnail với icon play)
              if (review.videoUrls.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: review.videoUrls.length,
                    itemBuilder: (context, index) {
                      final videoUrl = review.videoUrls[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: VideoThumbnailWidget(
                          videoUrl: videoUrl,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        // Đường kẻ phân cách giữa các bình luận
        const SizedBox(height: DSize.spaceBtwItem),
        // Đường kẻ phân cách giữa các bình luận
        const Divider(
          color: Colors.grey, // Màu xám
          thickness: 0.5, // Độ dày
          height: 20, // Khoảng cách trên dưới
        ),
      ],
    );
  }
}
