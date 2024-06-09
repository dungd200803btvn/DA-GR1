import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/common/widgets/brands/t_brand_cart.dart';
import 'package:t_store/common/widgets/products/sortable/sortable_product.dart';
import 'package:t_store/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:t_store/features/shop/controllers/brand_controller.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helper/cloud_helper_functions.dart';

import '../../models/brand_model.dart';

class BrandProducts extends StatelessWidget {
  const BrandProducts({super.key, required this.brand});

  final BrandModel brand;

  @override
  Widget build(BuildContext context) {
    final controller = BrandController.instance;
    return Scaffold(
      appBar: TAppBar(
        title: Text(brand.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(DSize.defaultspace),
          child: Column(
            children: [
              //Brand Detail
              TBrandCard(
                showBorder: true,
                brand: brand,
              ),
              SizedBox(
                height: DSize.spaceBtwSection,
              ),
              FutureBuilder(
                future: controller.getBrandProducts(brandId: brand.id),
                builder: (context, snapshot) {
                  const loader = TVerticalProductShimmer();
                  final widget = TCloudHelperFunctions.checkMultiRecordState(snapshot: snapshot,loader: loader);
                  if(widget!=null) return widget;
                  ///record found
                  final brandProducts = snapshot.data!;
                  return TSortableProducts(
                    products: brandProducts,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
