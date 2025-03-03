import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../review/model/review_model.dart';

class UserProfileInfo extends StatelessWidget {
  final ReviewModel review;
  const UserProfileInfo({super.key, required this.review, });

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('User').doc(review.userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              const CircleAvatar(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(lang.translate('loading'), style: Theme.of(context).textTheme.titleLarge),
            ],
          );
        }
        if (!snapshot.hasData || snapshot.hasError) {
          return Row(
            children: [
              const CircleAvatar(child: Icon(Icons.error)),
              const SizedBox(width: 8),
              Text(lang.translate('unknown'), style: Theme.of(context).textTheme.titleLarge),
            ],
          );
        }
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        String avatarUrl = userData['ProfilePicture'] ?? '';
        String displayName = userData['FirstName'] +" " +userData['LastName'] ?? lang.translate('anonymous');
        if(review.isAnonymous){
         avatarUrl = '';
         displayName = lang.translate('anonymous');
        }

        return Row(
          children: [
            review.isAnonymous? const CircleAvatar(backgroundImage: AssetImage(TImages.userProfileImage1)): CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(width: 8),
            Text(displayName, style: Theme.of(context).textTheme.titleLarge),
          ],
        );
      },
    );
  }
}
