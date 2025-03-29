import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_store_app/l10n/app_localizations.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helper/helper_function.dart';
import '../model/notification_model.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final formattedDate =  DateFormat('dd/MM/yyyy HH:mm').format(notification.timestamp);
    final lang = AppLocalizations.of(context);

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('notification_detail'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị hình ảnh: nếu có imageUrl thì dùng NetworkImage, ngược lại dùng hình ảnh mặc định từ assets
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (notification.imageUrl != null &&
                      notification.imageUrl!.isNotEmpty)
                      ? Image.network(
                    notification.imageUrl!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    "assets/images/content/user.png",
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Tiêu đề thông báo
              Text(
                notification.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: dark? DColor.white:DColor.dark,
                ),
              ),
              const SizedBox(height: 12),
                //message
              // Nội dung thông báo (text body)
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 18,
                  color: dark? DColor.white:DColor.dark,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              // Hiển thị ngày giờ và trạng thái đọc
              Row(
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: notification.read
                          ? Colors.green[100]
                          : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      notification.read ? lang.translate('have_read') : lang.translate('un_read'),
                      style: TextStyle(
                        fontSize: 14,
                        color: notification.read
                            ? Colors.green
                            : Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
