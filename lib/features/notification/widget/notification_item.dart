import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../model/notification_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Định dạng ngày giờ thông báo
    final formattedDate =
    DateFormat('dd/MM/yyyy HH:mm').format(notification.timestamp);
    final lang = AppLocalizations.of(context);
    final asset = notification.type=="points"? "assets/images/content/bonus_point.jpg":"assets/images/content/user.png";
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: notification.read ? Colors.white : Colors.blue[50],
      child: ListTile(
        contentPadding: const EdgeInsets.all(4),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: (notification.imageUrl != null &&
              notification.imageUrl!.isNotEmpty)
              ? NetworkImage(notification.imageUrl!)
              :  const AssetImage("assets/images/content/user.png")
          as ImageProvider,
          backgroundColor: Colors.grey[200],
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
            color: notification.read ? Colors.black87 : Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: notification.read ? Colors.black54 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  if (notification.read)
                     Text(
                      lang.translate('have_read'),
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                ],
              ),
            ],
          ),
        ),
        trailing:
             Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: notification.read ? Colors.green : Colors.redAccent,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}