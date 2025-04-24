import 'package:flutter/material.dart';

class MissionRewardChip extends StatelessWidget {
  final int reward;

  const MissionRewardChip({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.yellow.shade100,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 4),
          Text('$reward điểm'),
        ],
      ),
    );
  }
}
