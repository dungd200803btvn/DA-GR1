import 'package:app_my_app/features/bonus_point/controller/mission_controller.dart';
import 'package:app_my_app/features/bonus_point/model/user_mission_model.dart';
import 'package:app_my_app/l10n/app_localizations.dart';
import 'package:app_my_app/utils/enum/enum.dart';
import 'package:app_my_app/utils/helper/helper_function.dart';
import 'package:app_my_app/utils/popups/loader.dart';
import 'package:flutter/material.dart';
import '../../../utils/singleton/user_singleton.dart';
import '../model/mission_model.dart';

class StartMissionButton extends StatelessWidget {
  final MissionModel mission;
  final VoidCallback? onStarted;
  const StartMissionButton({super.key, required this.mission, this.onStarted});
  
  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    final userId = UserSession.instance.userId!;
    final MissionController missionController = MissionController.instance;
    return FutureBuilder<bool>(
      future: missionController.hasUserStartedMission(userId, mission.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return ElevatedButton.icon(
          onPressed: () async {
            try{
              final now = DateTime.now();
              final expired = DHelperFunctions.calculateExpiredAt(mission,  now);
              final userMission = UserMissionModel(
                  id: '',
                  missionId: mission.id,
                  type: mission.type,
                  status: UserMissionStatus.inProgress,
                  progress: 0,
                  startedAt: now,
                  expiredAt:  expired);
              await  missionController.startUserMission(userMission, userId);
              onStarted?.call();
              TLoader.customToast(message: 'Đã bắt đầu nhiệm vụ');
            }catch(e){
              print('Error in start mission: $e');
            }finally{

            }
          },
          icon: const Icon(Icons.play_arrow),
          label:  Text(lang.translate('start_mission')),
        );
      },
    );
  }
}
