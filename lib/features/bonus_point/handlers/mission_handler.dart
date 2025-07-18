import 'package:app_my_app/features/bonus_point/model/user_mission_model.dart';
import 'package:flutter/cupertino.dart';

abstract class MissionHandler {
  Future<void> handle(UserMissionModel mission, BuildContext context,{dynamic extraData});
}
