import 'package:app_my_app/features/bonus_point/handlers/high_value_order_handler.dart';
import 'package:app_my_app/features/bonus_point/handlers/write_review_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../../utils/enum/enum.dart';
import '../../../utils/singleton/user_singleton.dart';
import '../model/user_mission_model.dart';
import 'mission_handler.dart';

class MissionTracker {
  static final MissionTracker instance = MissionTracker._internal();
  MissionTracker._internal();

  final Map<MissionType, MissionHandler> _handlers = {
    MissionType.writeReview: WriteReviewMissionHandler(),
    MissionType.viewProduct: WriteReviewMissionHandler(),
    MissionType.viewBrand:WriteReviewMissionHandler(),
    MissionType.viewShop:WriteReviewMissionHandler(),
    MissionType.quickOrder:WriteReviewMissionHandler(),
    MissionType.highValueOrder: HighValueOrderMissionHandler()
  };

  Future<void> track(MissionType type,BuildContext context, {dynamic extraData}) async {
    final userId = UserSession.instance.userId;
    final snapshot = await FirebaseFirestore.instance
        .collection('User')
        .doc(userId)
        .collection('user_missions')
        .where('status', isEqualTo: 'inProgress')
        .get();

    final missions = snapshot.docs
        .map((doc) => UserMissionModel.fromMap(doc))
        .where((m) => m.type == type && m.isActive)
        .toList();

    for (final mission in missions) {
      await _handlers[type]?.handle(mission,context,extraData: extraData);
    }
  }
}
