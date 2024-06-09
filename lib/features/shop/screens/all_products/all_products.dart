import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:t_store/features/shop/controllers/product/all_products_controller.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helper/cloud_helper_functions.dart';
import 'package:t_store/utils/helper/helper_function.dart';

import '../../../../common/widgets/products/sortable/sortable_product.dart';
import '../../models/product_model.dart';
class AllProducts extends StatelessWidget {
  const AllProducts({super.key, required this.title, this.query, this.futureMethod});
  final String title;
  final Query? query;
  final Future<List<ProductModel>>? futureMethod;
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllProductsController());
    final dark = DHelperFunctions.isDarkMode(context);
    return  Scaffold(
      appBar: TAppBar(title: Text(title,selectionColor: dark? Colors.white:Colors.black,),showBackArrow: true,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          child: FutureBuilder(future:futureMethod ?? controller.fetchProductsByQuery(query) ,
          builder: ( context,  snapshot) {
            const loader = TVerticalProductShimmer();
            final widget =TCloudHelperFunctions.checkMultiRecordState(snapshot: snapshot ,loader: loader);
            if(widget!=null) return widget;
            final products = snapshot.data!;
            return TSortableProducts(products: products,);
          },
           ),
        ),
      ),
    );
  }
}


