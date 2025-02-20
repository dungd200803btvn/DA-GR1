import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/features/notification/controller/notification_controller.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key, });

  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.instance;
    return Obx(() {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications),
          if (controller.notificationCount.value > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${controller.notificationCount.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }
}
