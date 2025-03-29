import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lcd_ecommerce_app/features/shop/controllers/product/cart_controller.dart';
import 'package:lcd_ecommerce_app/features/shop/models/product_model.dart';
import 'package:lcd_ecommerce_app/features/shop/screens/product_details/product_detail.dart';
import 'package:lcd_ecommerce_app/utils/enum/enum.dart';
import 'package:lcd_ecommerce_app/utils/helper/event_logger.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class ProductCardAddtoCartButton extends StatelessWidget {
  const ProductCardAddtoCartButton({
    super.key,
    required this.product,
    this.salePercentage,
  });

  final ProductModel product;
  final  double? salePercentage;
  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    return GestureDetector(
      onTap: () async{
        if (product.productType == ProductType.single.toString()) {
          final cartItem = controller.toCartModel(product, 1,salePercentage);
          controller.addOneToCart(cartItem);
          await EventLogger().logEvent(eventName: 'add_to_cart',
          additionalData: {
            'product_id':product.id,
            'quantity_added': controller.productQuantityInCart.value,
            'sale_percentage':salePercentage,
            'product_type':product.productType
          });
        } else {
          await EventLogger().logEvent(
            eventName: "navigate_to_product_detail",
            additionalData: {
              'product_id': product.id,
              'product_type': product.productType,
            },
          );
          Get.to(()=> ProductDetailScreen(product: product,salePercentage: salePercentage,));
        }
      },
      child: Obx(() {
        final productQuantityInCart =controller.getProductQuantityInCart(product.id);
        return Container(
          decoration:  BoxDecoration(
              color: productQuantityInCart>0 ? DColor.primary:DColor.dark,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(DSize.cardRadiusMd),
                  bottomRight: Radius.circular(DSize.productImageRadius))),
          child:  SizedBox(
              width: DSize.iconLg * 1.2,
              height: DSize.iconLg * 1.2,
              child: Center(child: productQuantityInCart>0 ? Text(productQuantityInCart.toString(),style: Theme.of(context).textTheme.bodyLarge!.apply(color: DColor.white),)
              : Icon(Iconsax.add, color: DColor.white)
             )),
        );
      }),
    );
  }
}
