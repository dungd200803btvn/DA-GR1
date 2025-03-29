import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lcd_ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:lcd_ecommerce_app/features/personalization/controllers/address_controller.dart';
import 'package:lcd_ecommerce_app/l10n/app_localizations.dart';
import 'package:lcd_ecommerce_app/utils/constants/sizes.dart';
import 'package:lcd_ecommerce_app/utils/validators/validation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'address.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  _AddNewAddressScreenState createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final controller = AddressController.instance;
  // Các state cho dropdown địa giới hành chính
  List<dynamic> _cities = [];
  List<dynamic> _districts = [];
  List<dynamic> _wards = [];
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedWard;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchAddressData();
  }

  Future<void> _fetchAddressData() async {
    const url =
        'https://raw.githubusercontent.com/kenzouno1/DiaGioiHanhChinhVN/master/data.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _cities = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        // Xử lý lỗi nếu cần
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Xử lý lỗi nếu cần
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng AppLocalizations nếu bạn đang dùng i10n
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(lang.translate('add_address'),
        style: Theme.of(context).textTheme.headlineSmall),
      leadingOnPressed: ()=> Get.to(const UserAddressScreen()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          child: Form(
            key: controller.addressFormkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Họ và tên, số điện thoại, đường...
                TextFormField(
                  controller: controller.name,
                  validator: (value) =>
                      DValidator.validateEmptyText('Name', value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.user),
                    labelText: lang.translate('name'),
                  ),
                ),
                const SizedBox(height: DSize.spaceBtwInputFielRadius),
                TextFormField(
                  controller: controller.phoneNumber,
                  validator: DValidator.validatePhoneNumber,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.mobile),
                    labelText: lang.translate('phone_number'),
                  ),
                ),
                const SizedBox(height: DSize.spaceBtwInputFielRadius),
                TextFormField(
                  controller: controller.street,
                  validator: (value) =>
                      DValidator.validateEmptyText('Street', value),
                  decoration:  InputDecoration(
                    prefixIcon: Icon(Iconsax.building_31),
                    labelText: lang.translate('street'),
                  ),
                ),
                const SizedBox(height: DSize.spaceBtwInputFielRadius),
                // Dropdown chọn tỉnh thành (City)
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Iconsax.electricity),
                    labelText: lang.translate('select_province'),
                  ),
                  value: _selectedCity,
                  items: _cities.map<DropdownMenuItem<String>>((city) {
                    return DropdownMenuItem<String>(
                      value: city['Name'],
                      child: Text(city['Name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                      // Khi chọn tỉnh, cập nhật danh sách quận/huyện
                      final selectedCityObj = _cities.firstWhere(
                              (city) =>
                              city['Name'] == value,
                          orElse: () => null);
                      _districts = selectedCityObj?['Districts'] ?? [];
                      _selectedDistrict = null;
                      _wards = [];
                      _selectedWard = null;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return lang.translate('select_province');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DSize.spaceBtwInputFielRadius),
                // Dropdown chọn quận/huyện (District)
                DropdownButtonFormField<String>(
                  decoration:  InputDecoration(
                    prefixIcon: Icon(Iconsax.electricity1),
                    labelText: lang.translate('select_district'),
                  ),
                  value: _selectedDistrict,
                  items: _districts.map<DropdownMenuItem<String>>((district) {
                    return DropdownMenuItem<String>(
                      value: district['Name'],
                      child: Text(district['Name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                      // Khi chọn quận/huyện, cập nhật danh sách phường/xã
                      final selectedDistrictObj = _districts.firstWhere(
                              (district) =>
                              district['Name'] == value,
                          orElse: () => null);
                      _wards = selectedDistrictObj?['Wards'] ?? [];
                      _selectedWard = null;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return lang.translate('select_district');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DSize.spaceBtwInputFielRadius),
                // Dropdown chọn phường/xã (Ward)
                DropdownButtonFormField<String>(
                  decoration:  InputDecoration(
                    prefixIcon: Icon(Iconsax.electricity5),
                    labelText: lang.translate('select_district'),
                  ),
                  value: _selectedWard,
                  items: _wards.map<DropdownMenuItem<String>>((ward) {
                    return DropdownMenuItem<String>(
                      value: ward['Name'],
                      child: Text(ward['Name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWard = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return lang.translate('select_commune');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DSize.defaultspace),
                // Nút lưu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.addressFormkey.currentState!.validate()) {
                        controller.selectedCity = _selectedCity!;
                        controller.selectedDistrict = _selectedDistrict!;
                        controller.selectedWard = _selectedWard!;
                        controller.addNewAddresses();
                      }
                    },
                    child:  Text(lang.translate('save')),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
