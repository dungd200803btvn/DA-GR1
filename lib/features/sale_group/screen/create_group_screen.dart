import 'package:app_my_app/features/sale_group/controller/sale_group_controller.dart';
import 'package:app_my_app/utils/popups/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/api_constants.dart';

class CreateSaleGroupScreen extends StatefulWidget {
  const CreateSaleGroupScreen({super.key});
  @override
  _CreateSaleGroupScreenState createState() => _CreateSaleGroupScreenState();
}

class _CreateSaleGroupScreenState extends State<CreateSaleGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = SaleGroupController.instance;
  // late final SaleGroupController controller;
  @override
  void initState() {
    super.initState();
    // Xóa controller cũ nếu tồn tại
    // if (Get.isRegistered<SaleGroupController>()) {
    //   Get.delete<SaleGroupController>();
    // }
    // controller = Get.put(SaleGroupController());
  }
  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    Widget? dropdownWidget;

    if ( controller.selectedType != null) {
      List<DropdownMenuItem<String>> items = [];
      if (controller.selectedType == "shop") {
        items = controller.topShops
            .map((shop) => DropdownMenuItem<String>(
          value: shop.id,
          child: Text(shop.name),
        ))
            .toList();
      } else if (controller.selectedType == "brand") {
        items = controller.topBrands
            .map((brand) => DropdownMenuItem<String>(
          value: brand.id,
          child: Text(brand.name),
        ))
            .toList();
      } else if (controller.selectedType == "category") {
        items = controller.topCategories
            .map((category) => DropdownMenuItem<String>(
          value: category.id,
          child: Text(category.name),
        ))
            .toList();
      }

      dropdownWidget = DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Chọn ${controller.selectedType}",
        ),
        items: items,
        value: controller.selectedId,
        onChanged: (value) {
          setState(() {
            controller.selectedId = value;
            if (controller.selectedType == "shop") {
              final selectedShop = controller.topShops.firstWhere(
                    (shop) => shop.id == value,
              );
              controller.selectedName = selectedShop.name ?? "";
            } else if (controller.selectedType == "brand") {
              final selectedBrand = controller.topBrands.firstWhere(
                    (brand) => brand.id == value,
              );
              controller.selectedName = selectedBrand.name ?? "";
            } else if (controller.selectedType == "category") {
              final selectedCategory = controller.topCategories.firstWhere(
                    (category) => category.id == value,
              );
              controller.selectedName = selectedCategory.name ?? "";
            }
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Vui lòng chọn ${controller.selectedType}";
          }
          return null;
        },
      );
    }

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('create_sale_group'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: controller.groupNameController,
                decoration: InputDecoration(
                  labelText: lang.translate('group_name'),
                  border: const OutlineInputBorder()
                ),
                validator: (value){
                  if(value==null || value.trim().isEmpty){
                    return lang.translate('group_name_required');
                  }
                  return null;
                },
              ),
              SizedBox(height: 16,),
              Text(lang.translate('select_scope_apply'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ListTile(
                title: Text(lang.translate('shop')),
                leading: Radio<String>(
                  value: "shop",
                  groupValue: controller.selectedType,
                  onChanged: (value) {
                    setState(() {
                      controller.selectedType = value;
                      controller.selectedId = null;
                    });
                    controller.loadTopObjects(value!);
                  },
                ),
              ),
              ListTile(
                title:  Text(lang.translate('brand')),
                leading: Radio<String>(
                  value: "brand",
                  groupValue: controller.selectedType,
                  onChanged: (value) {
                    setState(() {
                      controller.selectedType = value;
                      controller.selectedId = null;
                    });
                    controller.loadTopObjects(value!);
                  },
                ),
              ),
              ListTile(
                title:  Text(lang.translate('category')),
                leading: Radio<String>(
                  value: "category",
                  groupValue: controller.selectedType,
                  onChanged: (value) {
                    setState(() {
                      controller.selectedType = value;
                      controller.selectedId = null;
                    });
                    controller.loadTopObjects(value!);
                  },
                ),
              ),
              // Nhập mã của đối tượng được chọn
              if (dropdownWidget != null) dropdownWidget,
              const SizedBox(height: 16),
              // Dropdown chọn số thành viên tối thiểu
              DropdownButtonFormField<int>(
                decoration:  InputDecoration(
                    labelText: lang.translate('select_minimum_members')),
                items: targetOptions
                    .map(
                      (option) => DropdownMenuItem<int>(
                    value: option,
                    child: Text(option.toString()),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    controller.selectedTargetParticipants = value;
                  });
                },
                validator: (value) =>
                value == null ? lang.translate('please_select_quantity') : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.isLoading
                    ? null
                    : () async {
                  if (_formKey.currentState!.validate())
                  {
                    _formKey.currentState!.save();
                    // Xác định discount dựa trên số thành viên được chọn
                    double discount;
                    int index = targetOptions.indexOf(controller.selectedTargetParticipants!);
                    if(index!=-1){
                      discount = discountOptions[index];
                    }else{
                      discount = 5.0;
                    }
                    final newGroup = await controller.onClickCreate(context,discount);
                    await controller.fetchSaleGroups();
                    _formKey.currentState?.reset();
                    Get.back(result: newGroup);
                  }
                },
                child: controller.isLoading
                    ? const CircularProgressIndicator()
                    :  Text(lang.translate('create_groups')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
