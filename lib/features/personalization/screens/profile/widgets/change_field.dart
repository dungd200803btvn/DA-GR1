import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/popups/full_screen_loader.dart';
import '../../../../../utils/popups/loader.dart';
import '../../../../../utils/validators/validation.dart';
import '../profile.dart';

enum FieldType { text, date }

/// Cấu hình cho mỗi trường cập nhật
class FieldConfig {
  final String label; // Tên hiển thị (có thể dùng key dịch)
  final String fieldName; // Key cập nhật trong DB (ví dụ: "FirstName")
  final FieldType fieldType;
  final TextEditingController? textController; // Dùng cho trường text
  DateTime? dateValue; // Dùng cho trường date

  FieldConfig({
    required this.label,
    required this.fieldName,
    required this.fieldType,
    this.textController,
    this.dateValue,
  });
}

/// Widget cập nhật thông tin người dùng có thể tái sử dụng
class ChangeProfileField extends StatefulWidget {
  final String title;
  final String successMessage;
  final List<FieldConfig> fields;
  /// Callback nhận vào Map chứa các trường cần update
  final Future<void> Function(Map<String, dynamic> updatedFields) onUpdate;

  const ChangeProfileField({
    super.key,
    required this.title,
    required this.successMessage,
    required this.fields,
    required this.onUpdate,
  });

  @override
  _ChangeProfileFieldState createState() => _ChangeProfileFieldState();
}

class _ChangeProfileFieldState extends State<ChangeProfileField> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(DSize.defaultspace),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần heading thông báo
              Text(
                widget.successMessage,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: DSize.spaceBtwSection),
              // Sinh ra các trường theo cấu hình truyền vào
              ...widget.fields.map((field) {
                if (field.fieldType == FieldType.text) {
                  return Column(
                    children: [
                      TextFormField(
                        controller: field.textController,
                        decoration: InputDecoration(
                          labelText: lang.translate(field.label),
                          prefixIcon: const Icon(Iconsax.user),
                        ),
                        validator: (value) =>
                            DValidator.validateEmptyText(field.fieldName, value),
                      ),
                      const SizedBox(height: DSize.spaceBtwInputFielRadius),
                    ],
                  );
                } else if (field.fieldType == FieldType.date) {
                  // Sử dụng TextFormField readOnly để hiển thị ngày và mở DatePicker khi bấm vào
                  return Column(
                    children: [
                      TextFormField(
                        controller: TextEditingController(
                          text: field.dateValue != null
                              ? DateFormat.yMd().format(field.dateValue!)
                              : '',
                        ),
                        decoration: InputDecoration(
                          labelText: lang.translate(field.label),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate:
                            field.dateValue ?? DateTime(2000, 1, 1),
                            firstDate: DateTime(1970),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              field.dateValue = pickedDate;
                            });
                          }
                        },
                        validator: (value) {
                          if (field.dateValue == null) {
                            return '${field.label} không được để trống';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: DSize.spaceBtwInputFielRadius),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: DSize.spaceBtwSection),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate form
                    if (!_formKey.currentState!.validate()) return;

                    // Tập hợp dữ liệu cần update
                    Map<String, dynamic> updatedData = {};
                    for (var field in widget.fields) {
                      if (field.fieldType == FieldType.text) {
                        updatedData[field.fieldName] = field.textController?.text.trim();
                        if (kDebugMode) {
                          print("Tên trường: ${field.fieldName}");
                          print("Giá trị của trường: ${field.textController?.text.trim()}");
                        }

                      } else if (field.fieldType == FieldType.date) {
                        updatedData[field.fieldName] = field.dateValue;
                      }
                    }

                    // Hiển thị loader
                    TFullScreenLoader.openLoadingDialog(
                        lang.translate('updating'), TImages.docerAnimation);
                    try {
                      // Gọi callback update (thường là cập nhật vào DB)
                      await widget.onUpdate(updatedData);
                      TFullScreenLoader.stopLoading();
                      TLoader.successSnackbar(
                        title: lang.translate('congratulations'),
                        message: widget.successMessage,
                      );
                      // Chuyển về trang profile hoặc trang trước đó
                      Get.off(() => const ProfileScreen());
                    } catch (e) {
                      TFullScreenLoader.stopLoading();
                      TLoader.errorSnackbar(
                        title: lang.translate('snap'),
                        message: e.toString(),
                      );
                    }
                  },
                  child: Text(lang.translate('save')),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
