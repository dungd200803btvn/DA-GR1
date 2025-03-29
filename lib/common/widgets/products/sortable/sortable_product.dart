import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:my_app/common/widgets/products/sortable/sort_option.dart';
import 'package:my_app/features/shop/controllers/product/all_products_controller.dart';
import 'package:my_app/features/shop/models/product_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/constants/sizes.dart';
import '../../layouts/grid_layout.dart';
import '../product_cards/product_card_vertical.dart';

class TSortableProducts extends StatelessWidget {
  const TSortableProducts({
    super.key, required this.products,
    this.applyDiscount = false
  });
 final List<ProductModel> products;
 final bool applyDiscount;
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllProductsController());
    // Di chuyển logic cập nhật trạng thái ra ngoài build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.assignProducts(products,context);
    });
    return Column(
      children: [
        //Drop down
        DropdownButtonFormField<SortOption>(
          items: SortOption.values.map((option) {
            return DropdownMenuItem<SortOption>(
              value: option,
              child: Text(option.getLabel(context)),
            );
          }).toList(),
          value: controller.selectedSortOption.value,
          onChanged: (SortOption? newOption) {
            if (newOption != null) {
              controller.sortProducts(newOption, context);
            }
          },
          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.sort)),
        ),

        const SizedBox(height: DSize.spaceBtwSection,),
        /// Products
        Obx((){
          final discounts  = applyDiscount? calculateDiscounts(products.length): [];
          return TGridLayout(
              itemCount: controller.products.length,
              itemBuilder: (_,index)=> TProductCardVertical(product: controller.products[index],salePercentage: applyDiscount? discounts[index]/100.0: null,));

    } ),
      ],
    );
  }

  // Tính toán giảm giá nếu cần
  List<double> calculateDiscounts(int count) {
    List<double> discounts = [];
    double discount = 30.0;
    for (int i = 0; i < count; i++) {
      if (discount > 10.0) {
        discounts.add(discount);
        discount -= 2.0;
      } else {
        discounts.add(10.0);
      }
    }
    return discounts;
  }
}