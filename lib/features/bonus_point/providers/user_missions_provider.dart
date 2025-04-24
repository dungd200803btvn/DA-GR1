import 'package:app_my_app/utils/singleton/user_singleton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../controller/mission_controller.dart';
import '../model/user_mission_model.dart';

final userMissionsProvider = AsyncNotifierProvider<UserMissionsNotifier, List<UserMissionModel>>(UserMissionsNotifier.new);

class UserMissionsNotifier extends AsyncNotifier<List<UserMissionModel>> {
  @override
  Future<List<UserMissionModel>> build() async {
    return await MissionController.instance.getUserMissions(UserSession.instance.userId!);
  }
}

final userMissionByMissionIdProvider = Provider.family<UserMissionModel?, String>((ref, missionId) {
  final userMissionsAsync = ref.watch(userMissionsProvider);

  return userMissionsAsync.when(
    data: (missions) => missions.firstWhereOrNull((e) => e.missionId == missionId),
    loading: () => null,
    error: (_, __) => null,
  );
});
