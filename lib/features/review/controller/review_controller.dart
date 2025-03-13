import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:t_store/data/repositories/user/user_repository.dart';
import 'package:t_store/utils/constants/api_constants.dart';
import 'package:t_store/utils/helper/cloud_helper_functions.dart';
import 'package:t_store/utils/popups/loader.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/review/review_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../notification/controller/notification_service.dart';
import '../model/review_model.dart';

class WriteReviewScreenController extends GetxController{
  static WriteReviewScreenController get instance => Get.find();
  final reviewRepository = ReviewRepository.instance;
  final userRepository  = UserRepository.instance;
  final TextEditingController commentController = TextEditingController();
  double rating = 0.0;
  bool isAnonymous = false;
  List<File> selectedImages = [];
  List<File> selectedVideos = [];
  final ImagePicker _picker = ImagePicker();
  late AppLocalizations lang;
  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }
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
  Future<void> submitReview(String productId, BuildContext context) async {
    // Hiển thị loading dialog
    TFullScreenLoader.openLoadingDialog(
        lang.translate('process_order'), TImages.pencilAnimation);
    try {
      final mediaUrls = await uploadMediaToStorage();
      final imageUrls = mediaUrls['imageUrls'] ?? [];
      final videoUrls = mediaUrls['videoUrls'] ?? [];

      ReviewModel review = ReviewModel(
        rating: rating,
        comment: commentController.text.trim(),
        isAnonymous: isAnonymous,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
        reviewId: '',
        productId: productId,
        userId: AuthenticationRepository.instance.authUser!.uid,
        videoUrls: videoUrls,
      );

      await reviewRepository.saveReview(review);

      final points = basePoints +
          (imageUrls.length * imageBonusPoints) +
          (videoUrls.length * videoBonusPoints);
      await userRepository.updateUserPoints(
          AuthenticationRepository.instance.authUser!.uid, points);
      // Xây dựng thông báo đa ngôn ngữ sử dụng placeholder đã được thay thế
      String baseMessage = lang.translate(
        'review_success_message',
        args: [basePoints.toString()],
      );
      String photoMessage = imageUrls.isNotEmpty
          ? lang.translate('upload_photo', args: [
        imageUrls.length.toString(),
        (imageUrls.length * imageBonusPoints).toString()
      ])
          : "";
      String videoMessage = videoUrls.isNotEmpty
          ? lang.translate('upload_video', args: [
        videoUrls.length.toString(),
        (videoUrls.length * videoBonusPoints).toString()
      ])
          : "";
      String mediaMessage =
          photoMessage + (videoMessage.isNotEmpty ? "\n" + videoMessage : "");
      String endMessage = lang.translate(
        'review_success_message_end',
        args: [points.toString()],
      );
      String finalMessage =
          baseMessage + (mediaMessage.isNotEmpty ? "\n" + mediaMessage : "")+endMessage;
      // Loại bỏ các ký tự ngoặc nhọn nếu còn sót lại
      finalMessage = finalMessage.replaceAll(RegExp(r'[{}]'), '');
      // Upload ảnh bonus để dùng cho thông báo
      String url = await  TCloudHelperFunctions.uploadAssetImage( "assets/images/content/bonus_point.jpg", "bonus_point");
      final NotificationService notificationService =
      NotificationService(userId: AuthenticationRepository.instance.authUser!.uid);
      await notificationService.createAndSendNotification(
        title: lang.translate('get_point_success'),
        message: finalMessage,
        type: "points",
        imageUrl: url,
      );
      // Reset dữ liệu sau khi submit thành công
      resetData();
    } catch (e) {
      // Xử lý lỗi theo yêu cầu, ví dụ hiển thị thông báo lỗi
      if (kDebugMode) {
        print("Error in submitReview: $e");
      }
    } finally {
      // Đóng loading dialog khi hoàn tất (dù thành công hay thất bại)
      TFullScreenLoader.stopLoading();
      Navigator.pop(context);
    }
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
