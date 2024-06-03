import 'package:get/get.dart';
import 'package:t_store/features/shop/controllers/product/images_controller.dart';
import 'package:t_store/features/shop/models/product_model.dart';
import 'package:t_store/features/shop/models/product_variation_model.dart';

class VariationController extends GetxController {
  static VariationController get instance => Get.find();

  //variables
  RxMap selectedAttributes = {}.obs;
  RxString variationStockStatus = "".obs;
  Rx<ProductVariationModel> selectedVariation =
      ProductVariationModel.empty().obs;

  ///select attributes and variations
  void onAttributeSelected(
      ProductModel product, attributeName, attributeValue) {
    final selectedAttributes =
        Map<String, dynamic>.from(this.selectedAttributes);
    selectedAttributes[attributeName] = attributeValue;
    this.selectedAttributes[attributeName] = attributeValue;
    final selectedVariation = product.productVariations!.firstWhere(
        (element) =>
            _isSameAttributeValues(element.attributeValues, selectedAttributes),
        orElse: () => ProductVariationModel.empty());
    //set main image to selected variation image
    if (selectedVariation.image.isNotEmpty) {
      ImagesController.instance.selectedProductImage.value =
          selectedVariation.image;
    }
    //assign selected variation
    this.selectedVariation.value = selectedVariation;
  }

  bool _isSameAttributeValues(Map<String, dynamic> variationAttributes,
      Map<String, dynamic> selectedAttributes) {
    if (variationAttributes.length != selectedAttributes.length) {
      return false;
    }
    for (final key in variationAttributes.keys) {
      if (variationAttributes[key] != selectedAttributes[key]) return false;
    }
    return true;
  }

//check attributes availability/stock in variation
  Set<String?> getAttributesAvailabilityVariation(
      List<ProductVariationModel> variations, String attributeName) {
    return variations
        .where((variation) =>
            variation.attributeValues[attributeName] != null &&
            variation.attributeValues[attributeName]!.isNotEmpty &&
            variation.stock > 0)
        .map((variation) => variation.attributeValues[attributeName])
        .toSet();
  }

  String getVariationPrice(){
    return (selectedVariation.value.salePrice>0 ? selectedVariation.value.salePrice:selectedVariation.value.price ).toString();
  }
  //check status
  void getProductVariationStockStatus() {
    variationStockStatus.value =
        selectedVariation.value.stock > 0 ? "In Stock" : "Out of stock";
  }

  //reset
  void resetSelectedAttributes() {
    selectedAttributes.clear();
    variationStockStatus.value = '';
    selectedVariation.value = ProductVariationModel.empty();
  }
}
