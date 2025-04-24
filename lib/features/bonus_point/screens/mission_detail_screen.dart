import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/enum/enum.dart';
import '../../../utils/singleton/user_singleton.dart';
import '../controller/mission_controller.dart';
import '../model/mission_model.dart';
import '../widgets/countdown.dart';
import '../widgets/mission_duration_chip.dart';
import '../widgets/mission_progress_indicator.dart';
import '../widgets/mission_reward_chip.dart';
import '../widgets/start_mission_button.dart';

class MissionDetailScreen extends StatefulWidget {
  final MissionModel mission;

  const MissionDetailScreen({super.key, required this.mission});

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  bool _hasStarted = false;
  bool _isExpired = false;
  bool _isCompleted = false;
  final missionController = MissionController.instance;
  @override
  void initState() {
    super.initState();
    _checkIfMissionStarted();
  }

  Future<void> _checkIfMissionStarted() async {
    final userId = UserSession.instance.userId!;
    final userMission = await missionController.getUserMissionById(userId, widget.mission.id);
    if (userMission != null) {
      setState(() {
        _hasStarted = userMission.isActive;
        _isExpired = userMission.isExpired;
        _isCompleted = userMission.status == UserMissionStatus.completed;
      });
    }
  }

  Future<void> _handleMissionExpired() async {
    final userId = UserSession.instance.userId!;
    final userMission = await missionController.getUserMissionById(userId, widget.mission.id);
    await missionController.updateUserMissionStatus(
      userId: userId,
      missionId: userMission!.id,
      status: UserMissionStatus.expired.name,
    );
    setState(() {
      _isExpired = true;
    });
  }

  void _onMissionStarted() {
    setState(() {
      _hasStarted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('mission_detail'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.mission.imgUrl ?? '',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(Icons.image),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              widget.mission.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Description
            Text(widget.mission.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            // Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: MissionRewardChip(reward: widget.mission.reward),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: MissionDurationChip(mission: widget.mission),
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child:  Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MissionProgressIndicator(userId: UserSession.instance.userId!, mission: widget.mission),
                  // Trạng thái nhiệm vụ
                  if (_isCompleted)
                    const Text(
                      '🎉 Bạn đã hoàn thành nhiệm vụ này!',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    )
                  else if (_isExpired)
                    Center(
                      child: const Text(
                        '⏰ Nhiệm vụ đã hết hạn và chưa hoàn thành.',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    )
                  else if (_hasStarted)
                    Center(
                      child: CountdownSection(
                        mission: widget.mission,
                        onExpired: _handleMissionExpired,
                      ),
                    )
                  else
                    Center(
                      child: StartMissionButton(
                        mission: widget.mission,
                        onStarted: _onMissionStarted,
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
