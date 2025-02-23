import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:t_store/utils/popups/loader.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/review/review_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../model/review_model.dart';

class WriteReviewScreenController extends GetxController{
  static WriteReviewScreenController get instance => Get.find();
  final reviewRepository = ReviewRepository.instance;
  final TextEditingController commentController = TextEditingController();
  double rating = 0.0;
  bool isAnonymous = false;
  List<File> selectedImages = [];
  List<File> selectedVideos = [];
  final ImagePicker _picker = ImagePicker();

  // Hàm mở thư viện ảnh hoặc camera
  Future<void> pickMedia(BuildContext context) async {
    var lang = AppLocalizations.of(context);
  await showModalBottomSheet(context: context,
      builder: (context)=>Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title:  Text(lang.translate('choose_photo_library')),
            onTap: ( )async{
              final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
              if(pickedFile!=null){
                selectedImages.add(File(pickedFile.path));
              }
              TLoader.successSnackbar(title: lang.translate('upload_photo_success'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title:  Text(lang.translate('choose_video_library')),
            onTap: () async {
              final XFile? pickedFile =
              await _picker.pickVideo(source: ImageSource.gallery);
              if (pickedFile != null) {
                selectedVideos.add(File(pickedFile.path));
              }
              TLoader.successSnackbar(title: lang.translate('upload_video_success'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title:  Text(lang.translate('take_photo')),
            onTap: () async {
              final XFile? pickedFile =
              await _picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                selectedImages.add(File(pickedFile.path));
              }
              TLoader.successSnackbar(title: lang.translate('upload_photo_success'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title:  Text(lang.translate('take_video')),
            onTap: () async {
              final XFile? pickedFile =
              await _picker.pickVideo(source: ImageSource.camera);
              if (pickedFile != null) {
                selectedVideos.add(File(pickedFile.path));
              }
              TLoader.successSnackbar(title: lang.translate('upload_video_success'));
              Navigator.pop(context);
            },
          ),
        ],
      ));
  }

  Future<Map<String, List<String>>> uploadMediaToStorage() async {
    List<String> uploadedImageUrls = [];
    List<String> uploadedVideoUrls = [];
    // Upload ảnh
    for (var image in selectedImages) {
      try {
        String fileName =
            'reviews/images/${DateTime.now().millisecondsSinceEpoch}_${image.hashCode}.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(image);
        String url = await ref.getDownloadURL();
        uploadedImageUrls.add(url);
      } catch (e) {
        debugPrint('Lỗi upload ảnh: $e');
      }
    }
    // Upload video
    for (var video in selectedVideos) {
      try {
        String fileName =
            'reviews/videos/${DateTime.now().millisecondsSinceEpoch}_${video.hashCode}.mp4';
        Reference ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(video);
        String url = await ref.getDownloadURL();
        uploadedVideoUrls.add(url);
      } catch (e) {
        debugPrint('Lỗi upload video: $e');
      }
    }

    return {
      'imageUrls': uploadedImageUrls,
      'videoUrls': uploadedVideoUrls,
    };
  }

  // Hàm xử lý gửi đánh giá
  Future<void> submitReview(String productId) async {
    final mediaUrls = await uploadMediaToStorage();
    ReviewModel review = ReviewModel(
      rating: rating,
      comment: commentController.text.trim(),
      isAnonymous: isAnonymous,
      imageUrls: mediaUrls['imageUrls'] ?? [],
      createdAt: DateTime.now(),
      reviewId: '',
      productId: productId,
      userId: AuthenticationRepository.instance.authUser!.uid,
      videoUrls: mediaUrls['videoUrls'] ?? [],
    );

    await reviewRepository.saveReview(review);
    // Reset dữ liệu sau khi submit thành công
    resetData();
  }
  /// Hàm reset toàn bộ dữ liệu đã nhập
  void resetData() {
    commentController.clear();
    selectedImages.clear();
    selectedVideos.clear();
    rating = 0;
    isAnonymous = false;
  }

  Future<int> fetchTotalReviews(
      String productId, {
        int? filterRating,
        bool filterWithMedia = false,
        bool sortByTime = true,
      }) async {
    List<ReviewModel> reviews = await getReviewsByProductId(
      productId,
      filterRating: filterRating,
      filterHasMedia: filterWithMedia,
      sortByTime: sortByTime,
    );
    return reviews.length;
  }

  Future<double> getAverageRatingByProductId(String productId, {
    int? filterRating,
    bool filterWithMedia = false,
    bool sortByTime = true,
  }) async{
    List<ReviewModel> reviews = await getReviewsByProductId(
      productId,
      filterRating: filterRating,
      filterHasMedia: filterWithMedia,
      sortByTime: sortByTime,
    );
    double totalRatings = 0.0;
    for(var review in reviews){
      totalRatings+= review.rating;
    }
    return reviews.isNotEmpty? totalRatings/reviews.length:0.0;
  }

  Future<List<ReviewModel>> getReviewsByProductId(String productId,{
    int? filterRating,
    bool filterHasMedia =false,
    bool sortByTime = true
  }) async{
    List<ReviewModel> reviews = await reviewRepository.getReviewsByProductId(productId);
      if(filterHasMedia){
        reviews = reviews.where((r)=> r.imageUrls.isNotEmpty|| r.videoUrls.isNotEmpty).toList();
      }
      if(filterRating!=null){
        reviews = reviews.where((r)=> r.rating == filterRating).toList();
      }
      if(sortByTime){
        reviews.sort((a,b)=> b.createdAt.compareTo(a.createdAt));
      }else{
        reviews.sort((a,b)=> b.rating.compareTo(a.rating));
      }
    return reviews;
  }

  // Hàm dọn dẹp bộ nhớ
  @override
  void dispose() {
    super.dispose();
  }
}
