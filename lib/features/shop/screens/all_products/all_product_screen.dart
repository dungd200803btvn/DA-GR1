import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/products/sortable/sortable_product.dart';
import 'all_product_controller.dart';

class AllProductScreen extends StatefulWidget {
  final String title;
  final String filterType;
  final String filterId;
  final bool applyDiscount;

  const AllProductScreen({
    super.key,
    required this.title,
    this.applyDiscount = false,
    required this.filterType,
    required this.filterId,
  });

  @override
  _AllProductScreenState createState() => _AllProductScreenState();
}

class _AllProductScreenState extends State<AllProductScreen> {
  late final AllProductController controller;
  @override
  void initState() {
    super.initState();
    // Xóa controller cũ nếu tồn tại
    if (Get.isRegistered<AllProductController>()) {
      Get.delete<AllProductController>();
    }
    controller = Get.put(AllProductController(), tag: widget.filterId);
    controller.fetchProducts(
        filterType: widget.filterType, filterId: widget.filterId);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: TAppBar(
        title: Text(widget.title),
        showBackArrow: true,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Hiển thị danh sách sản phẩm
                TSortableProducts(
                  products: controller.displayedProducts,
                  applyDiscount: widget.applyDiscount,
                ),
                const SizedBox(height: 16),
                // Nút "Xem thêm" nếu còn dữ liệu (nextPageToken không null)
                if (controller.hasMore.value)
                  controller.isLoadingMore.value
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () {
                      controller.loadMoreProducts();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black45,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("Xem thêm"),
                  )
                else if (controller.products.isNotEmpty)
                  const Text("Đã xem hết sản phẩm"),
              ],
            ),
          ),
        );
      }),
    );
  }
}
