import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../l10n/app_localizations.dart';
import '../controller/mission_controller.dart';
import '../model/mission_model.dart';
import '../providers/mission_list_provider.dart';
import '../widgets/mission_card.dart';

// class MissionListScreen extends StatelessWidget {
//   const MissionListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = MissionController.instance;
//     var lang = AppLocalizations.of(context);
//     return Scaffold(
//       appBar: TAppBar(
//         title: Text(
//           lang.translate('mission_list_screen'),
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//         showBackArrow: true,
//       ),
//       body: FutureBuilder<List<MissionModel>>(
//         future: controller.fetchAllMissions(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("Không có nhiệm vụ nào hiện tại."));
//           }
//           final missions = snapshot.data!;
//           return ListView.separated(
//             padding: const EdgeInsets.all(16),
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemCount: missions.length,
//             itemBuilder: (context, index) {
//               final mission = missions[index];
//               return MissionCard(mission:mission);
//             },
//           );
//         },
//       ),
//     );
//   }
// }

class MissionListScreen extends ConsumerWidget {
  const MissionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = AppLocalizations.of(context);
    final missionListAsync = ref.watch(missionListProvider);

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('mission_list_screen'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: missionListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Lỗi khi tải nhiệm vụ: $e")),
        data: (missions) {
          if (missions.isEmpty) {
            return const Center(child: Text("Không có nhiệm vụ nào hiện tại."));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: missions.length,
            itemBuilder: (context, index) {
              final mission = missions[index];
              return MissionCard(mission: mission);
            },
          );
        },
      ),
    );
  }
}

