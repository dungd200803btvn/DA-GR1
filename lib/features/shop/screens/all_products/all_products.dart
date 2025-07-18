import 'package:app_my_app/features/shop/controllers/recommendation_controller.dart';
import 'package:app_my_app/utils/singleton/user_singleton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_my_app/common/widgets/appbar/appbar.dart';
import 'package:app_my_app/features/shop/controllers/product/all_products_controller.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
import 'package:app_my_app/utils/helper/helper_function.dart';
import '../../../../common/widgets/products/sortable/sortable_product.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../models/product_model.dart';

class AllProducts extends StatelessWidget {
  const AllProducts(
      {super.key,
      required this.title,
      this.query,
      this.futureMethod,
      this.products,
      this.applyDiscount = false});

  final bool applyDiscount;
  final String title;
  final Query? query;
  final Future<List<ProductModel>>? futureMethod;
  final List<ProductModel>? products;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllProductsController());
    final recommendationController = RecommendationController.instance;
    final dark = DHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          title,
          style: TextStyle(color: dark ? Colors.white : Colors.black),
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          child: Column(
            children: [
              products!=null? TSortableProducts(
                products: products!,
                applyDiscount: applyDiscount,
              ):
              FutureBuilder(
                future: futureMethod ?? controller.fetchProductsByQuery(query),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      TFullScreenLoader.openLoadingDialog(
                        'Loading products now...',
                        TImages.loaderAnimation,
                      );
                    });
                    return const SizedBox(); // Không hiển thị gì khi đang loading
                  } else {
                    // Khi dữ liệu có sẵn, đóng dialog loading
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      TFullScreenLoader.stopLoading();
                    });
                  }
                  final products = snapshot.data!;
                  return TSortableProducts(
                    products: products,
                    applyDiscount: applyDiscount,
                  );
                },
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  recommendationController.isLoaded.value = false;
                  recommendationController.fetchRecommendations(UserSession.instance.userId!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black45,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("Refresh lại danh sách"),
              )
            ],
          )
        ),
      ),
    );
  }
}
