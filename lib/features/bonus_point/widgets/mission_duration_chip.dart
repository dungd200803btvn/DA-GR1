import 'package:flutter/material.dart';
import '../../../utils/enum/enum.dart';
import '../model/mission_model.dart';

class MissionDurationChip extends StatelessWidget {
  final MissionModel mission;
  const MissionDurationChip({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (mission.durationType) {
      case MissionDurationType.daily:
        label = "Hạn 24h";
        color = Colors.redAccent;
        break;
      case MissionDurationType.weekly:
        label = "Trong tuần";
        color = Colors.orangeAccent;
        break;
      case MissionDurationType.customRange:
        label = "Từ ${_formatDate(mission.startTime)} → ${_formatDate(mission.endTime)}";
        color = Colors.blueAccent;
        break;
      default:
        label = "Không giới hạn";
        color = Colors.grey;
    }

    return Chip(
      backgroundColor: color.withOpacity(0.2),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.day}/${date.month}";
  }
}
