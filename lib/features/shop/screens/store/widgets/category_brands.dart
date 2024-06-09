import 'package:flutter/material.dart';
import 'package:t_store/common/widgets/brands/branch_show_case.dart';
import 'package:t_store/common/widgets/shimmer/boxes_shimmer.dart';
import 'package:t_store/common/widgets/shimmer/list_tile_shimmer.dart';
import 'package:t_store/features/shop/controllers/brand_controller.dart';
import 'package:t_store/features/shop/models/category_model.dart';
import 'package:t_store/utils/constants/image_strings.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helper/cloud_helper_functions.dart';

class CategoryBrands extends StatelessWidget {
  const CategoryBrands({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final controller = BrandController.instance;

    return FutureBuilder(
        future: controller.getBrandsForCategory(category.id),
        builder: (context, snapshot) {
          const loader = Column(
            children: [
              TListTileShimmer(),
              SizedBox(
                height: DSize.spaceBtwItem,
              ),
              //TBoxesShimmer(),
              SizedBox(
                height: DSize.spaceBtwItem,
              ),
            ],
          );
          final widget = TCloudHelperFunctions.checkMultiRecordState(
              snapshot: snapshot, loader: loader);
          if (widget != null) return widget;
          final brands = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: brands.length,
            itemBuilder: (_, index) {
              final brand = brands[index];
              return FutureBuilder(
                  future: controller.getBrandProducts(brandId: brand.id,limit: 3),
                  builder: (context, snapshot) {
                   // handle loader, no record, or error message
                    final widget = TCloudHelperFunctions.checkMultiRecordState(
                        snapshot: snapshot, loader: loader);
                    if (widget != null) return widget;
                   // record found!
                    final products = snapshot.data!;
                    return TBrandShowCase(
                      brand: brand,
                      images: products.map((product) => product.thumbnail).toList(),
                    );
                  });
            },
          );
        });
  }
}
