import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../features/shop/models/shop_model.dart';

class ShopRepository extends GetxController{
  static ShopRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;
  Future<ShopModel> getShopById(String shopId) async{
    try{
      DocumentSnapshot<Map<String,dynamic>> snapshot =  await _db.collection('Shops').doc(shopId).get();
      if(snapshot.exists){
        return  ShopModel.fromSnapshot(snapshot);
      }else{
        return ShopModel.empty();
      }
    }catch(e){
      print('Loi: getShopById: ${e.toString()} ');
    }
    return ShopModel.empty();
  }

  /// Lấy top shops theo giới hạn truyền vào (mặc định 20)
  Future<List<ShopModel>> fetchTopShops({int limit = 20}) async {
    try {
      // 1. Lấy toàn bộ products
      QuerySnapshot productSnapshot =
      await _db.collection('Products').get();
      print("Retrieved ${productSnapshot.docs.length} products");

      // 2. Đếm số lượng sản phẩm cho mỗi shop
      Map<String, int> shopCount = {};
      for (var doc in productSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String? shopId = data['shop_id'];
        if (shopId != null) {
          shopCount[shopId] = (shopCount[shopId] ?? 0) + 1;
        }
      }

      // 3. Sắp xếp các shop_id theo số lượng giảm dần và lấy top theo giới hạn
      List<String> sortedShopIds = shopCount.keys.toList()
        ..sort((a, b) => shopCount[b]!.compareTo(shopCount[a]!));
      sortedShopIds = sortedShopIds.take(limit).toList();

      // 4. Truy vấn bảng Shops theo sortedShopIds với batch
      List<Map<String, dynamic>> shops = [];
      const int batchSize = 10;
      for (int i = 0; i < sortedShopIds.length; i += batchSize) {
        final int end =
        (i + batchSize < sortedShopIds.length) ? i + batchSize : sortedShopIds.length;
        final List<String> batchIds = sortedShopIds.sublist(i, end);
        QuerySnapshot shopSnapshot = await _db
            .collection('Shops')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();
        for (var doc in shopSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          data['productCount'] = shopCount[doc.id];
          shops.add(data);
        }
      }

      // 5. Sắp xếp lại các shop theo số lượng sản phẩm giảm dần
      shops.sort((a, b) =>
          (b['productCount'] as int).compareTo(a['productCount'] as int));
      print("Successfully fetched top shops.");
      final List<ShopModel> shopsModel = shops
          .map((jsonItem) => ShopModel.fromJson(jsonItem))
          .toList();
      return shopsModel;
    } catch (error) {
      print("Error retrieving top shops: $error");
      rethrow;
    }
  }
}