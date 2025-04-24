import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/enum/enum.dart';

class MissionModel {
  final String id;
  final String title;
  final String description;
  final int reward;
  final MissionType type;
  final int goal; // Số lượng cần đạt để hoàn thành (ví dụ: 5 reviews, 3 orders...)
  final int? threshold; // Dành cho nhiệm vụ có điều kiện giá trị (VD: > 1 triệu)
  final MissionDurationType durationType;      // mới
  final int? durationInHours;                  // mới: chỉ dùng nếu type là customRange
  final DateTime? startTime;                   // mới: nếu cần khởi tạo từ thời điểm cụ thể
  final DateTime? endTime;
  final String? imgUrl;
  MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.type,
    required this.goal,
    this.threshold,
    this.durationType = MissionDurationType.none,
    this.durationInHours,
    this.startTime,
    this.endTime,
    this.imgUrl
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reward': reward,
      'type': type.name,
      'goal': goal,
      'threshold': threshold,
      'durationType': durationType.name,
      'durationInHours': durationInHours,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'imgUrl':imgUrl
    };
  }

  factory MissionModel.fromMap(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map<String, dynamic>;
    return MissionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      reward: map['reward'] ?? 0,
      type: MissionType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => MissionType.writeReview,
      ),
      goal: map['goal'] ?? 0,
      threshold: map['threshold'],
      durationType: MissionDurationType.values.firstWhere(
            (e) => e.name == map['durationType'],
        orElse: () => MissionDurationType.none,
      ),
      durationInHours: map['durationInHours'],
      startTime: map['startTime'] != null
          ? DateTime.tryParse(map['startTime'])
          : null,
      endTime: map['endTime'] != null
          ? DateTime.tryParse(map['endTime'])
          : null,
      imgUrl: map['imgUrl'] as String?,
    );
  }
}
