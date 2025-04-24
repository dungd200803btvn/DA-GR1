import 'package:app_my_app/features/bonus_point/model/mission_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/enum/enum.dart';
import '../model/user_mission_model.dart';
import '../providers/user_missions_provider.dart';
import '../screens/mission_detail_screen.dart';

// class MissionCard extends StatelessWidget {
//
//   final MissionModel mission;
//   const MissionCard({super.key, required this.mission});
//
//   @override
//   Widget build(BuildContext context) {
//
//     return InkWell(
//       onTap: (){
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MissionDetailScreen(mission: mission),
//           ),
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         elevation: 4,
//         color: Colors.white,
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Mission icon or image
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: mission.imgUrl != null
//                     ? CachedNetworkImage(
//                         imageUrl: mission.imgUrl!,
//                         width: 60,
//                         height: 60,
//                         fit: BoxFit.cover,
//                         placeholder: (_, __) => const CircularProgressIndicator(),
//                         errorWidget: (_, __, ___) =>
//                             const Icon(Icons.image_not_supported),
//                       )
//                     : Container(
//                         width: 60,
//                         height: 60,
//                         color: Colors.deepPurple.shade50,
//                         child: const Icon(
//                           Icons.image_not_supported,
//                           size: 30,
//                           color: Colors.deepPurple,
//                         ),
//                       ),
//               ),
//               const SizedBox(width: 12),
//               // Text info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       mission.title,
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       mission.description,
//                       style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//                     ),
//                     const SizedBox(height: 6),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class MissionCard extends ConsumerWidget {
  final MissionModel mission;

  const MissionCard({super.key, required this.mission});

  String getStatusText(UserMissionStatus? status, BuildContext context,UserMissionModel? misssion) {
    final lang = AppLocalizations.of(context);
    if(status==null){
      return lang.translate('not_started');
    }
    if(misssion==null){
      return lang.translate('not_started');
    }
    if(misssion.isExpired){
      return lang.translate('expired');
    }
    switch (status) {
      case UserMissionStatus.inProgress:
        return lang.translate('pending');
      case UserMissionStatus.completed:
        return lang.translate('completed');
      case UserMissionStatus.expired:
        return lang.translate('expired');
      default:
        return "Not Started";
    }
  }

  Color getStatusColor(UserMissionStatus? status,UserMissionModel? misssion) {
    if(status==null){
      return Colors.blue;
    }
    if(misssion==null){
      return Colors.blue;
    }
    if(misssion.isExpired){
      return Colors.red;
    }
    switch (status) {
      case UserMissionStatus.inProgress:
        return Colors.orange;
      case UserMissionStatus.completed:
        return Colors.green;
      case UserMissionStatus.expired:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userMission = ref.watch(userMissionByMissionIdProvider(mission.id));

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MissionDetailScreen(mission: mission),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Mission image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: mission.imgUrl != null
                    ? CachedNetworkImage(
                        imageUrl: mission.imgUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator()),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.deepPurple.shade50,
                        child: const Icon(Icons.image_not_supported,
                            size: 30, color: Colors.deepPurple),
                      ),
              ),
              const SizedBox(width: 12),
              // Mission info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mission.description,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatusColor(userMission?.status,userMission)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          getStatusText(userMission?.status, context,userMission),
                          style: TextStyle(
                            color: getStatusColor(userMission?.status,userMission),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
