import 'package:app_my_app/utils/singleton/user_singleton.dart';
import 'package:flutter/cupertino.dart';
import '../controller/mission_controller.dart';
import '../model/mission_model.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class CountdownSection extends StatefulWidget {
  final MissionModel mission;
  final VoidCallback onExpired;
  const CountdownSection({super.key, required this.mission, required this.onExpired});

  @override
  State<CountdownSection> createState() => _CountdownSectionState();
}

class _CountdownSectionState extends State<CountdownSection> {
  Duration? _remaining;
  Duration? _totalDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUserMissionAndStartTimer();
  }

  void _loadUserMissionAndStartTimer() async {
    final userId = UserSession.instance.userId!;
    final missionController = MissionController.instance;

    try {
      final userMission = await missionController.getUserMissionById(userId, widget.mission.id);
      final expiredAt = userMission?.expiredAt;
      final startedAt = userMission?.startedAt;

      if (expiredAt != null && startedAt != null) {
        final total = expiredAt.difference(startedAt);
        setState(() {
          _totalDuration = total;
        });

        _updateRemaining(expiredAt);

        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          _updateRemaining(expiredAt);
        });
      }else{
        setState(() {
          _remaining = null;
          _totalDuration = null;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi load user mission: $e');
    }
  }

  void _updateRemaining(DateTime expiredAt) {
    final now = DateTime.now();
    final remaining = expiredAt.difference(now);

    if (!mounted) return;
    if (remaining.isNegative) {
      _timer?.cancel();
      widget.onExpired;
    }else{
      setState(() {
        _remaining = remaining;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m ${seconds}s';
    } else {
      return '${hours}h ${minutes}m ${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_remaining == null || _totalDuration == null) {
      return const Text(
        'Nhiệm vụ không có giới hạn thời gian',
        style: TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      );
    }
    if (_remaining == Duration.zero) {
      return const Text('Đã hết thời gian');
    }

    final progress =
        1.0 - (_remaining!.inSeconds / _totalDuration!.inSeconds).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Thời gian còn lại',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            Text(
              _formatDuration(_remaining!),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
