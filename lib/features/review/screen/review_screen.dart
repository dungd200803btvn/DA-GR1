import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:t_store/features/shop/models/cart_item_model.dart';
import 'package:t_store/utils/popups/loader.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../l10n/app_localizations.dart';
import '../controller/review_controller.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key, required this.item});
  final CartItemModel item;
  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}
class _WriteReviewScreenState extends State<WriteReviewScreen> {
   final controller = WriteReviewScreenController.instance;
  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('write_review'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin sản phẩm
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh sản phẩm
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // Thay thế bằng ảnh thực tế
                  child: Image.network(
                    widget.item.image!,
                    fit: BoxFit.cover,
                  ),
                ),
                // Thông tin sản phẩm (tên, phân loại)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                    if (widget.item.selectedVariation != null &&
                widget.item.selectedVariation!['Color'] != null &&
                widget.item.selectedVariation!['Size'] != null)
        Text(
      "${widget.item.selectedVariation!['Color']}, ${widget.item.selectedVariation!['Size']}",
        style: textTheme.bodyMedium,
      )
        else
        const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tiêu đề đánh giá sao
            Text(
              lang.translate('rating_hint'),
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Thanh đánh giá sao
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              maxRating: 5,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 32,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  controller.rating = rating ;
                });
              },
            ),
            const SizedBox(height: 16),

            // Tiêu đề viết đánh giá + bộ đếm ký tự
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang.translate('write_review'),
                  style: textTheme.titleMedium,
                ),
                Text(
                  '${controller.commentController.text.length}/300',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Ô nhập bình luận
            TextField(
              controller: controller.commentController,
              maxLength: 300,
              maxLines: 5,
              onChanged: (value) {
                setState(() {}); // Cập nhật bộ đếm
              },
              decoration: InputDecoration(
                hintText:
               lang.translate('hint_text_comment'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Thêm ảnh hoặc video
            Text(
              lang.translate('add_photo'),
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            InkWell(
              onTap: () {
              controller.pickMedia(context);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Row(
                  children: [
                    const Icon(Icons.add_a_photo),
                    const SizedBox(width: 8),
                    Text( lang.translate('add_photo'),),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Đánh giá ẩn danh
            Row(
              children: [
                Checkbox(
                  value: controller.isAnonymous,
                  onChanged: (bool? value) {
                    setState(() {
                      controller.isAnonymous = value ?? false;
                    });
                  },
                ),
                 Text(lang.translate('anonymous_review'),),
              ],
            ),
            const SizedBox(height: 24),

            // Nút Gửi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{
                 controller.submitReview(widget.item.productId,context);
                },
                child:  Text(lang.translate('submit'),),
              ),
            ),
          ],
        ),
      ),
    );
  }
   @override
   void dispose() {
     controller.dispose();
     super.dispose();
   }
}
