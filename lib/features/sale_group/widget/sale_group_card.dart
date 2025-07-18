import 'package:app_my_app/utils/formatter/formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/enum/enum.dart';
import '../model/sale_group_model.dart';
import '../screen/group_detail_screen.dart';

class GroupCard extends StatelessWidget {
  final SaleGroupModel group;
  const GroupCard({super.key, required this.group});

  String getStatusText(SaleGroupStatus status,BuildContext context) {
    final lang = AppLocalizations.of(context);
    switch (status) {
      case SaleGroupStatus.pending:
        return lang.translate('pending');
      case SaleGroupStatus.completed:
        return lang.translate('completed');
      case SaleGroupStatus.expired:
        return lang.translate('expired');
      case SaleGroupStatus.canceled:
        return lang.translate('canceled');
      default:
        return "";
    }
  }

  Color getStatusColor(SaleGroupStatus status) {
    switch (status) {
      case SaleGroupStatus.pending:
        return Colors.orange;
      case SaleGroupStatus.completed:
        return Colors.green;
      case SaleGroupStatus.expired:
        return Colors.red;
      case SaleGroupStatus.canceled:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    String scopeType = "";
    if (group.shopId != null) {
      scopeType = "Shop";
    } else if (group.brandId != null) {
      scopeType = "Brand";
    } else if (group.categoryId != null) {
      scopeType = "Category";
    }
    return GestureDetector(
      onTap: () {
        // Chuyển sang màn hình chi tiết khi nhấn vào Card
        Get.to(() => GroupDetailScreen(group: group));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // tăng độ cong cho card
        ),
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Scope & status
              Text('${lang.translate('group_name')}: ${group.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "$scopeType: ${group.selectedObjectName}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: getStatusColor(group.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      getStatusText(group.status, context),
                      style: TextStyle(
                        color: getStatusColor(group.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Thông tin discount và số thành viên
              Row(
                children: [
                  Text(
                    "${lang.translate('sale')}: ${group.discount.toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${group.currentParticipants}/${group.targetParticipants} ${lang.translate('member')}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Thời gian hết hạn
              Text(
                "${lang.translate('expired')}: ${DFormatter.FormattedDate(group.createdAt.add(const Duration(hours: 24)))}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}
