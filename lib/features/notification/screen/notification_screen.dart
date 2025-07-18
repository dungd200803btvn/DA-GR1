import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../controller/notification_controller.dart';
import '../model/notification_model.dart';
import '../widget/notification_item.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  final bool showBackArrow ;
  const NotificationScreen({super.key,  this.showBackArrow = true});
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<NotificationModel>> _futureNotifications;
  final controller = NotificationController.instance;
  Future<void> markNotificationAsRead(NotificationModel notification) async {
    await controller.markNotificationAsRead(AuthenticationRepository.instance.authUser!.uid, notification.id);
    setState(() {
      notification.read = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _futureNotifications = controller.getAllNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return Scaffold(
        appBar: TAppBar(
          title: Text(
            lang.translate('notification'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          showBackArrow: widget.showBackArrow,
        ),
        body: RefreshIndicator(
            child: FutureBuilder<List<NotificationModel>>(
              future: _futureNotifications,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("${lang.translate('error')}: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(lang.translate('no_notification')));
                }

                final notifications = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationItem(
                      notification: notification,
                      onTap: () async{
                        if (!notification.read) {
                          await markNotificationAsRead(notification);
                        }
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NotificationDetailScreen(notification: notification),
                          ),
                        );
                        setState(() {
                          _futureNotifications = controller.getAllNotifications();
                        });
                      },
                    );
                  },
                );
              },
            ),
            onRefresh: () async {
              setState(() {
                _futureNotifications = controller.getAllNotifications();
              });
            }));
  }
}
