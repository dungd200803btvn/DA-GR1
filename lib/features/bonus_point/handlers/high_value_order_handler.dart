import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../../data/repositories/bonus_point/mission_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/enum/enum.dart';
import '../../../utils/helper/cloud_helper_functions.dart';
import '../../../utils/singleton/user_singleton.dart';
import '../../notification/controller/notification_service.dart';
import '../model/user_mission_model.dart';
import 'mission_handler.dart';

class HighValueOrderMissionHandler extends MissionHandler {
  @override
  Future<void> handle(UserMissionModel mission, BuildContext context,{dynamic extraData}) async {
    if (!mission.isActive) return;
    var lang = AppLocalizations.of(context);
    final double orderValue = extraData as double;
    final newProgress = mission.progress + 1;
    final missionModel = await MissionRepository.instance.getMissionById(mission.missionId);
    print("Bat dau nhiem vu ${missionModel.description}");
    if (orderValue < missionModel.threshold!) return;
    final completed = newProgress >= missionModel.goal;
    final userId = UserSession.instance.userId;
    await FirebaseFirestore.instance
        .collection('User')
        .doc(userId)
        .collection('user_missions')
        .doc(mission.id)
        .set({
      'progress': newProgress,
      'status': completed ? UserMissionStatus.completed.name : UserMissionStatus.inProgress.name,
      'completedAt': completed ? FieldValue.serverTimestamp() : null,
    }, SetOptions(merge: true));
    print("Hoan thanh nhiem vu ${missionModel.description}");
    if(completed){
      await UserRepository.instance.updateUserPoints(userId!, missionModel.reward);
      String baseMessage = lang.translate(
        'mission_completed_message',
        args: [missionModel.description,missionModel.reward.toString()],
      );
      String finalMessage = baseMessage.replaceAll(RegExp(r'[{}]'), '');
      // Upload ảnh bonus để dùng cho thông báo
      String url = await  TCloudHelperFunctions.uploadAssetImage( "assets/images/content/bonus_point.jpg", "bonus_point");
      await NotificationService.instance.createAndSendNotification(
        title: missionModel.title,
        message: finalMessage,
        type: "points",
        imageUrl: url,
      );
    }
  }
}
