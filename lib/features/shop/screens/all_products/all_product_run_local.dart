import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store_app/common/widgets/appbar/appbar.dart';
import 'package:t_store_app/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:t_store_app/features/shop/controllers/product/all_products_controller.dart';
import 'package:t_store_app/utils/constants/sizes.dart';
import 'package:t_store_app/utils/helper/cloud_helper_functions.dart';
import 'package:t_store_app/utils/helper/helper_function.dart';

import '../../../../common/widgets/products/sortable/sortable_product.dart';
import '../../controllers/home_controller.dart';
import '../../models/product_model.dart';

class AllProductsByLocal extends StatelessWidget {
  const AllProductsByLocal({
    super.key,
    required this.title,
  });
  final String title;
  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final HomeController controller = Get.find();
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          title,
          style: TextStyle(color: dark ? Colors.white : Colors.black),
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Obx(
            ()=> Padding(
            padding: const EdgeInsets.all(DSize.defaultspace),
            child: TSortableProducts(products:controller.filteredProducts.value ,),
            ),
        ),
        ),
    );
  }
}
