import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:t_store/features/personalization/controllers/address_controller.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loader.dart';
import '../../../../utils/validators/validation.dart';
import '../../models/address_model.dart';
import 'address.dart';

class EditAddressScreen extends StatefulWidget {
  final AddressModel address;
  const EditAddressScreen({super.key, required this.address});

  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {

  final _formKey = GlobalKey<FormState>();
  final controller = AddressController.instance;
  // Controllers cho các TextField
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  // Danh sách dữ liệu cho dropdown
  List<dynamic> _cities = [];
  List<dynamic> _districts = [];
  List<dynamic> _wards = [];
  // Các biến lưu giá trị được chọn
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedWard;
  // Switch chọn địa chỉ mặc định
  bool _defaultAddress = false;
  // Loading indicator cho dữ liệu dropdown
  bool _isLoading = true;
  // Lưu lại giá trị ban đầu để kiểm tra form có thay đổi hay không
  late AddressModel _originalAddress;
  @override
  void initState() {
    super.initState();
    _originalAddress = widget.address;
    _nameController = TextEditingController(text: widget.address.name);
    _phoneController = TextEditingController(text: widget.address.phoneNumber);
    _streetController = TextEditingController(text: widget.address.street);
    // Gán giá trị mặc định từ model (lưu tên thay vì id)
    _selectedCity = widget.address.city;
    _selectedDistrict = widget.address.district;
    _selectedWard = widget.address.commune; // commune được hiểu là phường/xã
    _defaultAddress = widget.address.selectedAddress;
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
          // Nếu đã có chọn tỉnh thì cập nhật danh sách quận/huyện
          if (_selectedCity != null && _selectedCity!.isNotEmpty) {
            final selectedCityObj = _cities.firstWhere(
                    (city) => city['Name'] == _selectedCity,
                orElse: () => null);
            _districts = selectedCityObj?['Districts'] ?? [];
            // Nếu đã có chọn quận/huyện thì cập nhật danh sách phường/xã
            if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) {
              final selectedDistrictObj = _districts.firstWhere(
                      (district) => district['Name'] == _selectedDistrict,
                  orElse: () => null);
              _wards = selectedDistrictObj?['Wards'] ?? [];
            }
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // Hàm cập nhật địa chỉ
  void _updateAddress(BuildContext context) async {
    final lang = AppLocalizations.of(context);
    if (_formKey.currentState!.validate()) {
      // Hiển thị loading animation
      TFullScreenLoader.openLoadingDialog(lang.translate('update_address'), TImages.docerAnimation);
      final updatedAddress = AddressModel(
        id: widget.address.id,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        city: _selectedCity ?? '',
        district: _selectedDistrict ?? '',
        commune: _selectedWard ?? '',
        country: 'Việt Nam',
        dateTime: DateTime.now(),
        selectedAddress: _defaultAddress,
      );

      try {
        if(_defaultAddress){
          await controller.selectAddress(updatedAddress);
        }
        // Đợi quá trình cập nhật hoàn thành
        await controller.updateAddress(
          AuthenticationRepository.instance.authUser!.uid,
          updatedAddress,
        );

        // Dừng loader sau khi cập nhật xong
        TFullScreenLoader.stopLoading();

        // Hiển thị thông báo thành công
        TLoader.successSnackbar(
            title: lang.translate('congratulations'),
            message: lang.translate('update_address_success_msg')
        );
        Get.to(() => const UserAddressScreen());

      } catch (e) {
        // Dừng loader nếu có lỗi
        TFullScreenLoader.stopLoading();
        // Hiển thị thông báo lỗi
        TLoader.errorSnackbar(
            title: lang.translate('error'),
            message: lang.translate('error')+ e.toString()
        );
      }
    }
  }


  // Hàm xóa địa chỉ
  void _deleteAddress() async {
    final lang = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text(lang.translate('delete_address')),
        content:Text(lang.translate('delete_address_msg')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child:  Text(lang.translate('cancel'))),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child:  Text(lang.translate('delete'))),
        ],
      ),
    );
    if (confirm == true) {
      TFullScreenLoader.openLoadingDialog(lang.translate('delete_address'), TImages.docerAnimation);
      await controller.deleteAddress(AuthenticationRepository.instance.authUser!.uid, widget.address.id);
      TFullScreenLoader.stopLoading();
      TLoader.successSnackbar(title: lang.translate('delete_address'), message: lang.translate('delete_address_success_msg'));
      Get.to(() => const UserAddressScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(lang.translate('edit_address'),style: Theme.of(context).textTheme.headlineSmall,),
        leadingOnPressed: ()=> Get.to(const UserAddressScreen())
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TextField: Name
                TextFormField(
                  controller: _nameController,
                  validator: (value) =>
                      DValidator.validateEmptyText('Name', value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: lang.translate('name'),
                  ),
                ),
                const SizedBox(height: DSize.spaceBtwInputFielRadius),
                // TextField: Phone number
                TextFormField(
                  controller: _phoneController,
                  validator: DValidator.validatePhoneNumber,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone),
                    labelText: lang.translate('phone_number'),
                  ),
                ),
                const SizedBox(height: DSize.spaceBtwInputFielRadius),
                // TextField: Street
                TextFormField(
                  controller: _streetController,
                  validator: (value) =>
                      DValidator.validateEmptyText('Street', value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on),
                    labelText: lang.translate('street'),
                  ),
                ),
                const SizedBox(height: DSize.spaceBtwInputFielRadius),
                // Dropdown: Tỉnh thành (City)
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.location_city),
                    labelText: lang.translate('select_province'),
                  ),
                  value: _selectedCity,
                  items: _cities.map<DropdownMenuItem<String>>((city) {
                    return DropdownMenuItem<String>(
                      value: city['Name'], // lưu tên thành phố
                      child: Text(city['Name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                      final selectedCityObj = _cities.firstWhere(
                              (city) => city['Name'] == value,
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
                // Dropdown: Quận/Huyện (District)
                DropdownButtonFormField<String>(
                  decoration:  InputDecoration(
                    prefixIcon: Icon(Iconsax.activity),
                    labelText: lang.translate('select_district'),
                  ),
                  value: _selectedDistrict,
                  items: _districts.map<DropdownMenuItem<String>>((district) {
                    return DropdownMenuItem<String>(
                      value: district['Name'], // lưu tên quận/huyện
                      child: Text(district['Name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                      final selectedDistrictObj = _districts.firstWhere(
                              (district) => district['Name'] == value,
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
                // Dropdown: Phường/Xã (Ward/Commune)
                DropdownButtonFormField<String>(
                  decoration:  InputDecoration(
                    prefixIcon: Icon(Iconsax.code),
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
                      return lang.translate('select_district');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DSize.spaceBtwInputFielRadius),
                // Switch: Đặt làm địa chỉ mặc định
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(lang.translate('default_address')),
                    Switch(
                      value: _defaultAddress,
                      onChanged: (value) {
                        setState(() {
                          _defaultAddress = value;
                        });

                      },
                    ),
                  ],
                ),
                const SizedBox(height: DSize.spaceBtwInputFielRadius),
                // Nút: Xóa và Hoàn thành
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: _deleteAddress,
                        child:  Text(lang.translate('cancel')),
                      ),
                    ),
                    const SizedBox(width: DSize.defaultspace),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async{
                          _updateAddress(context);
                        },
                        child:  Text(lang.translate('complete')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
