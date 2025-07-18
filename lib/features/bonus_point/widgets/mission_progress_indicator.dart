import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/mission_model.dart';

class MissionProgressIndicator extends StatelessWidget {
  final String userId;
  final MissionModel mission;

  const MissionProgressIndicator({
    super.key,
    required this.userId,
    required this.mission,
  });

  @override
  Widget build(BuildContext context) {
    final goal = mission.goal; // Giả sử goal nằm trong mission model

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('User')
          .doc(userId)
          .collection('user_missions')
          .where('missionId', isEqualTo: mission.id)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("Bắt đầu nhiệm vụ ngay");
        }

        final data = snapshot.data!.docs.first.data();
        final progress = data['progress'] ?? 0;
        final percent = (progress / goal).clamp(0.0, 1.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Đã làm: $progress / $goal"),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              width: 120,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 120, // kích thước vòng tròn thật
                      width: 120,
                      child: CircularProgressIndicator(
                        value: percent,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                    Text(
                      "${(percent * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
