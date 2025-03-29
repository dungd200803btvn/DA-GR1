import 'package:flutter/material.dart';
import 'package:lcd_ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:lcd_ecommerce_app/features/review/widget/rating_tab_bar.dart';
import 'package:lcd_ecommerce_app/features/shop/screens/product_reviews/widgets/list_review.dart';
import 'package:lcd_ecommerce_app/features/shop/screens/product_reviews/widgets/rating_progress_indicator.dart';
import 'package:lcd_ecommerce_app/l10n/app_localizations.dart';
import 'package:lcd_ecommerce_app/utils/constants/sizes.dart';
import '../../../../common/widgets/products/ratings/rating_indicator.dart';
import '../../../../utils/helper/event_logger.dart';
import '../../../review/controller/review_controller.dart';

class ProductReviewScreen extends StatefulWidget {
  const ProductReviewScreen({super.key, required this.productId});
  final String productId;
  @override
  State<ProductReviewScreen> createState() => _ProductReviewScreenState();
}

class _ProductReviewScreenState extends State<ProductReviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // true: sắp xếp theo thời gian (mặc định); false: sắp xếp theo rating
  bool sortByTime = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Cập nhật UI khi tab thay đổi
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  /// Nếu tab 0 (index 0) được chọn, ta lọc review có media.
  /// Nếu tab 1 đến 5 được chọn, ta lọc theo rating (5, 4, 3, 2, 1)
  int? get filterRating {
    if (_tabController.index >= 2) {
      switch (_tabController.index) {
        case 2:
          return 5;
        case 3:
          return 4;
        case 4:
          return 3;
        case 5:
          return 2;
        case 6:
          return 1;
      }
    }
    return null;
  }

  bool get filterWithMedia => _tabController.index == 1;

  @override
  Widget build(BuildContext context) {
    final controller = WriteReviewScreenController.instance;
    var lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('review_and_rating'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          // Thanh TabBar kèm icon sắp xếp (cuộn ngang)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSize.defaultspace),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: lang.translate('total')),
                      Tab(text: lang.translate('has_media')), // "Có ảnh/Video"
                      const RatingTabBar(rating: "5"),
                      const RatingTabBar(rating: "4"),
                      const RatingTabBar(rating: "3"),
                      const RatingTabBar(rating: "2"),
                      const RatingTabBar(rating: "1"),
                    ],
                    onTap: (index) async {
                      String tabLabel;
                      if (index == 0) {
                        tabLabel = lang.translate('total');
                      } else if (index == 1) {
                        tabLabel = lang.translate('has_media');
                      } else {
                        // Với các tab đánh giá: tab index 2 đến 6
                        // Ta tính rating = (7 - index) vì:
                        // index 2 -> rating "5", index 3 -> rating "4", ...
                        int rating = 7 - index;
                        tabLabel = rating.toString();
                      }
                      await EventLogger().logEvent(
                        eventName: 'select_review_tab',
                        additionalData: {
                          'tab_label': tabLabel,
                          'product_id': widget.productId
                        },
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    sortByTime ? Icons.access_time : Icons.star,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      sortByTime = !sortByTime;
                    });
                  },
                ),
              ],
            ),
          ),
          // Nội dung chính (scrollable)
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(DSize.defaultspace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall product rating
                    TOverallProductRating(productId: widget.productId,
                      filterRating: filterRating,
                      filterWithMedia: filterWithMedia,
                      sortByTime: sortByTime,),
                    // Rating bar indicator
                    TRatingBarIndicator(productId: widget.productId,
                      filterRating: filterRating,
                      filterWithMedia: filterWithMedia,
                      sortByTime: sortByTime,),
                    // Tổng số review (đã lọc)
                    FutureBuilder<int>(
                        future: controller.fetchTotalReviews(
                          widget.productId,
                          filterRating: filterRating,
                          filterWithMedia: filterWithMedia,
                          sortByTime: sortByTime,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Text("?",
                                style: TextStyle(color: Colors.red));
                          }
                          int totalReviews = snapshot.data ?? 0;
                          return Text(
                            '${lang.translate('total_review')} $totalReviews',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        }),
                    const SizedBox(
                      height: DSize.spaceBtwSection,
                    ),
                    // Danh sách review (đã lọc)
                    ReviewListWidget(
                      productId: widget.productId,
                      filterRating: filterRating,
                      filterWithMedia: filterWithMedia,
                      sortByTime: sortByTime,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


