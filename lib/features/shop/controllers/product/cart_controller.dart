import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:t_store/features/shop/controllers/product/variation_controller.dart';
import 'package:t_store/features/shop/models/cart_item_model.dart';
import 'package:t_store/features/shop/models/product_model.dart';
import 'package:t_store/l10n/app_localizations.dart';
import 'package:t_store/utils/enum/enum.dart';
import 'package:t_store/utils/local_storage/storage_utility.dart';
import 'package:t_store/utils/popups/loader.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();
  ///variables
  RxInt numOfCartItems = 0.obs;
  RxDouble totalCartPrice = 0.0.obs;
  RxInt productQuantityInCart = 0.obs;
  RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final variationController = VariationController.instance;
  late AppLocalizations lang;
  CartController(){
    loadCartItems();
  }
  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }
  ///add items in the cart
  void addToCart(ProductModel product,[double? salePercentage]) {
    //quantity check
    if (productQuantityInCart.value < 1) {
      TLoader.customToast(message: lang.translate('select_quantity'));
      return;
    }
    //variation selected
    if (product.productType == ProductType.variable.toString() &&
        variationController.selectedVariation.value.id.isEmpty) {
      TLoader.customToast(message: lang.translate('select_variation'));
      return;
    }
    //Out of Stock Status
    if (product.productType == ProductType.variable.toString()) {
      if (variationController.selectedVariation.value.stock < 1) {
        TLoader.warningSnackbar(
            title: lang.translate('snap'), message: lang.translate('select_variation_err'));
        return;
      }
    } else {
      if (product.stock < 1) {
        TLoader.warningSnackbar(
            title: lang.translate('snap'), message: lang.translate('select_product_err'));
        return;
      }
    }
    //convert to cartItem with the given quantity
    final selectedCartItem = toCartModel(product, productQuantityInCart.value,salePercentage);
    //check if already added in cart
    int index = cartItems.indexWhere((cartItem) =>cartItem.productId  == selectedCartItem.productId && cartItem.variationId== selectedCartItem.variationId);
    if(index>=0){
      cartItems[index].quantity = selectedCartItem.quantity;
    }else{
      cartItems.add(selectedCartItem);
    }
    updateCart();
    TLoader.customToast(message: lang.translate('add_to_cart'));
  }

void  addOneToCart(CartItemModel item){
    int index = cartItems.indexWhere((cartItem) => cartItem.productId == item.productId && cartItem.variationId == item.variationId);
    if(index>=0){
      cartItems[index].quantity+=1;
    }else{
      cartItems.add(item);
    }
    updateCart();
}

void removeOneFromCart(CartItemModel item){
  int index = cartItems.indexWhere((cartItem) => cartItem.productId == item.productId && cartItem.variationId == item.variationId);
  if(index>=0){
    if(cartItems[index].quantity>1){
      cartItems[index].quantity-=1;
    }else{
      cartItems[index].quantity ==1? removeFromCartDialog(index): cartItems.removeAt(index);
    }
    updateCart();
  }
}

void removeFromCartDialog(int index){
    Get.defaultDialog(
      title: lang.translate('remove_product'),
      middleText: lang.translate('remove_product_msg'),
      onConfirm: (){
        cartItems.removeAt(index);
        updateCart();
        TLoader.customToast(message: lang.translate('remove_product_success'));
        Get.back();
      },
      onCancel: ()=>  ()=> Get.back(),
    );
}

  CartItemModel toCartModel(ProductModel product, int quantity,[double? salePercentage ]) {
    if (product.productType == ProductType.single.toString()) {
      variationController.resetSelectedAttributes();
    }
    final variation = variationController.selectedVariation.value;
    final isVariation = variation.id.isNotEmpty;
    final price = isVariation
        ? salePercentage!=null
            ? variation.price*(1-salePercentage)
            : variation.price
        : salePercentage!=null
            ? product.price*(1-salePercentage)
            : product.price;
    return CartItemModel(
        productId: product.id,
        title: product.title,
        category: product.categoryId!=null ? product.categoryId!  : " ",
        price: price,
        quantity: quantity,
    variationId: variation.id,
    image: isVariation? variation.image: product.thumbnail,
    brandName: product.brand!=null ? product.brand!.name : " ",
    selectedVariation: isVariation?   variation.attributeValues : null);
  }
  void updateCart(){
    updateCartTotals();
    saveCartItems();
    cartItems.refresh();
  }
  void updateCartTotals(){
    double totalPrice = 0.0;
    int totalItems = 0;
    for(var item in cartItems){
      totalPrice+= (item.price)* item.quantity.toDouble();
      totalItems+= item.quantity;
    }
    totalCartPrice.value = totalPrice;
    numOfCartItems.value = totalItems;
  }
  void saveCartItems(){
    final cartItemStrings = cartItems.map((element) => element.toJson()).toList();
    DLocalStorage.instance().writeData('cartItems',cartItemStrings);
  }
  void loadCartItems(){
    final cartItemStrings = DLocalStorage.instance().readData<List<dynamic>>('cartItems');
    if(cartItemStrings!=null){
      cartItems.assignAll(cartItemStrings.map((item) => CartItemModel.fromJson(item as Map<String,dynamic>)));
      updateCartTotals();
    }
  }
  int getProductQuantityInCart(String productId){
    final foundItem = cartItems.where((item) => item.productId == productId).fold(0, (previousValue, element) => previousValue+ element.quantity);
    return foundItem;
  }
  int getVariationQuantityInCart(String productId,String variationId){
    final foundItem = cartItems.firstWhere((item) => item.productId == productId && item.variationId ==variationId, orElse: ()=>CartItemModel.empty());
    return foundItem.quantity;
  }
  void clearCart(){
    productQuantityInCart.value =0;
    cartItems.clear();
    updateCart();
  }

  void updateAlreadyAddedProductCount(ProductModel product,[double? salePercentage]){
    if (salePercentage != null) {
      // Tìm sản phẩm trong giỏ hàng
      final foundItem = cartItems.firstWhereOrNull((item) => item.productId == product.id);
      if (foundItem != null) {
        // Cập nhật giá của sản phẩm với khuyến mãi
        foundItem.price = product.price * (1 - salePercentage);
      }
    }
    if(product.productType == ProductType.single.toString()){
      productQuantityInCart.value = getProductQuantityInCart(product.id);
    }else{
      final variationId = variationController.selectedVariation.value.id;
      if(variationId.isNotEmpty){
        productQuantityInCart.value = getVariationQuantityInCart(product.id, variationId);
      }else{
        productQuantityInCart.value =0;
      }
    }
  }
}
