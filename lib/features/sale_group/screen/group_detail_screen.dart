import 'dart:async';
import 'package:app_my_app/features/sale_group/controller/invite_group_controller.dart';
import 'package:app_my_app/features/sale_group/controller/sale_group_controller.dart';
import 'package:app_my_app/l10n/app_localizations.dart';
import 'package:app_my_app/utils/enum/enum.dart';
import 'package:app_my_app/utils/formatter/formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../shop/screens/product_reviews/widgets/profile.dart';
import '../model/sale_group_model.dart';
import 'invite_group_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final SaleGroupModel group;

  const GroupDetailScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final SaleGroupController controller = SaleGroupController.instance;
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    final createdAt = widget.group.createdAt;
    final endTime = createdAt.add(const Duration(hours: 24));
    _remaining = endTime.difference(DateTime.now());
    // Chỉ countdown khi group đang ở trạng thái pending
    if (widget.group.status == SaleGroupStatus.pending) {
      if (_remaining.isNegative) {
        _handleExpired();
      } else {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          final timeLeft = endTime.difference(DateTime.now());
          if (timeLeft.isNegative) {
            _handleExpired();
            timer.cancel();
          } else {
            setState(() {
              _remaining = timeLeft;
            });
          }
        });
      }
    }
  }

  void _handleExpired() async {
    if (widget.group.status == SaleGroupStatus.pending) {
      await controller.updateGroupStatus(widget.group.id, 'expired');
      await controller.sendNotificationWhenGroupExpired(widget.group);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    final progress = widget.group.currentParticipants / widget.group.targetParticipants;

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('group_detail'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
        actions: widget.group.status == SaleGroupStatus.pending
            ? [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'invite') {
                Get.to(() => InviteFriendToGroupScreen(group: widget.group));
              } else if (value == 'delete') {
                InviteGroupController.instance
                    .showDeleteConfirmation(context, widget.group);
              } else if (value == 'share_social') {
                InviteGroupController.instance
                    .showShareOptions(context, widget.group);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'invite',
                child: Text(lang.translate('invite_group')),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(lang.translate('delete_group')),
              ),
              PopupMenuItem(
                value: 'share_social',
                child: Text(lang.translate('share_social')),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          )
        ]
            : [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (widget.group.status == SaleGroupStatus.pending)
              _buildCountdownTimer(_remaining),
            const SizedBox(height: 12),
            _buildInfoTile(Icons.label, lang.translate('group_name'), widget.group.name),
            _buildInfoTile(Icons.category, lang.translate('scope_apply'), widget.group.selectedObjectName),
            _buildInfoTile(Icons.discount, lang.translate('sale'), "${widget.group.discount}%"),
            _buildInfoTile(Icons.people, lang.translate('member'),
                "${widget.group.currentParticipants}/${widget.group.targetParticipants}"),
            _buildInfoTile(Icons.date_range, lang.translate('creat_at'),
                DFormatter.FormattedDate(widget.group.createdAt)),
            _buildInfoTile(Icons.flag, lang.translate('status'),
                widget.group.status.toString().split('.').last.toUpperCase()),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${lang.translate('member_list')} (${widget.group.currentParticipants})",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...widget.group.participants.map((memberId) => UserInfo(userId: memberId)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(label),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// Countdown hiển thị dưới dạng HH:mm:ss
Widget _buildCountdownTimer(Duration remaining) {
  final hours = remaining.inHours.toString().padLeft(2, '0');
  final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.timer, color: Colors.red),
      const SizedBox(width: 8),
      Text(
        "$hours:$minutes:$seconds",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
      ),
    ],
  );
}
