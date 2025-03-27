import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/products/sortable/sortable_product.dart';
import 'all_product_controller.dart';

// class AllProductScreen extends StatelessWidget {
//   final String title;
//   final String categoryId;
//   final bool applyDiscount;
//
//   const AllProductScreen({
//     super.key,
//     required this.title,
//     required this.categoryId,
//     this.applyDiscount = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(AllProductController());
//     controller.fetchProductsByCategory(categoryId);
//     return Scaffold(
//       appBar: TAppBar(
//         title: Text(title),
//         showBackArrow: true,
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value && controller.products.isEmpty) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // Hiển thị danh sách sản phẩm
//                 TSortableProducts(
//                   products: controller.products,
//                   applyDiscount: applyDiscount,
//                 ),
//                 const SizedBox(height: 16),
//                 // Nút "Xem thêm" nếu còn dữ liệu (nextPageToken không null)
//                 if (controller.nextPageToken != null)
//                   ElevatedButton(
//                     onPressed: () {
//                       controller.loadMoreProducts();
//                     },
//                     child: controller.isLoadingMore.value
//                         ? const CircularProgressIndicator(
//                       color: Colors.white,
//                     )
//                         : const Text("Xem thêm"),
//                   ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }

class AllProductScreen extends StatefulWidget {
  final String title;
  final String filterType;
  final String filterId;
  final bool applyDiscount;

  const AllProductScreen({
    super.key,
    required this.title,
    this.applyDiscount = false, required this.filterType, required this.filterId,
  });

  @override
  _AllProductScreenState createState() => _AllProductScreenState();
}

class _AllProductScreenState extends State<AllProductScreen> {
  late final AllProductController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AllProductController());
    controller.fetchProducts(filterType: widget.filterType, filterId: widget.filterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: Text(widget.title),
        showBackArrow: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Hiển thị danh sách sản phẩm
                TSortableProducts(
                  products: controller.products,
                  applyDiscount: widget.applyDiscount,
                ),
                const SizedBox(height: 16),
                // Nút "Xem thêm" nếu còn dữ liệu (nextPageToken không null)
                if (controller.nextPageToken != null)
                  ElevatedButton(
                    onPressed: () {
                      controller.loadMoreProducts();
                    },
                    child: controller.isLoadingMore.value
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text("Xem thêm"),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
