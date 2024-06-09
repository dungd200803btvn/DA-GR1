import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/common/widgets/brands/t_brand_cart.dart';
import 'package:t_store/common/widgets/layouts/grid_layout.dart';
import 'package:t_store/common/widgets/products/sortable/sortable_product.dart';
import 'package:t_store/common/widgets/texts/section_heading.dart';
import 'package:t_store/features/shop/controllers/brand_controller.dart';
import 'package:t_store/features/shop/screens/brand/brand_products.dart';
import 'package:t_store/utils/constants/sizes.dart';

import '../../../../common/widgets/shimmer/brands_shimmer.dart';
import '../../models/brand_model.dart';
class AllBrandsScreen extends StatelessWidget {
  const AllBrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = BrandController.instance;
    return Scaffold(
      appBar: const TAppBar(title: Text('Brand'),showBackArrow: true,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          child: Column(
            children: [
              //Heading
              const TSectionHeading(title: 'Brand',showActionButton: false,),
              const SizedBox(height: DSize.spaceBtwItem,),
              //Brands
              Obx(
                    (){
                  if(controller.isLoading.value) return const TBrandsShimmer();
                  if(controller.allBrands.isEmpty) return Center(child: Text("No Data Found!",style: Theme.of(context).textTheme.bodyMedium!.apply(color: Colors.white),),);

                  return TGridLayout(
                      itemCount: controller.allBrands.length,
                      mainAxisExtent: 80,
                      itemBuilder: (_, index) {
                        final brand = controller.allBrands[index];
                        return  TBrandCard(showBorder: true, brand: brand,
                        onTap: ()=> Get.to(()=>BrandProducts(brand:brand,)),);
                      });
                } ,
              )
            ],
          ),
        ),
      ),
    );
  }
}
