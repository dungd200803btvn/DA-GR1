import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/mission_controller.dart';
import '../model/mission_model.dart';

final missionListProvider = AsyncNotifierProvider<MissionListNotifier, List<MissionModel>>(MissionListNotifier.new);

class MissionListNotifier extends AsyncNotifier<List<MissionModel>> {
  @override
  Future<List<MissionModel>> build() async {
    final missions = await MissionController.instance.fetchAllMissions();
    return missions;
  }
}
