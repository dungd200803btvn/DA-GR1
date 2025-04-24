import 'package:get/get.dart';
import '../../../data/repositories/bonus_point/mission_repository.dart';
import '../model/mission_model.dart';
import '../model/user_mission_model.dart';

class MissionController extends GetxController{
  static MissionController get instance => Get.find();
  final MissionRepository missionRepository = MissionRepository.instance;

  final RxBool isLoading = false.obs;

  Future<List<MissionModel>> fetchAllMissions() async {
    try {
      isLoading.value = true;
      return await missionRepository.getAllMissions();
    } catch (e) {
      print("Error: $e");
      return [];
    } finally {
      isLoading.value = false;
    }
  }
  Future<List<UserMissionModel>> getUserMissions(String userId) async{
    return await missionRepository.getUserMissions(userId);
  }

  Future<void> startUserMission(UserMissionModel userMission,String userId) async{
    await missionRepository.startUserMission(userMission, userId);
  }
  Future<bool> hasUserStartedMission(String userId, String missionId) async{
    return await missionRepository.hasUserStartedMission(userId, missionId);
  }
  Future<UserMissionModel?> getUserMissionById(String userId,String missionId) async{
    return await missionRepository.getUserMissionById(userId, missionId);
  }
  Future<void> updateUserMissionStatus({
    required String userId,
    required String missionId,
    required String status,
  }) async {
    await missionRepository.updateUserMissionStatus(userId: userId, missionId: missionId, status: status);
  }

}
