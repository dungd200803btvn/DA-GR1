import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class UserInfo extends StatefulWidget {
  final String userId;
  const UserInfo({super.key, required this.userId});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  late Future<DocumentSnapshot> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = FirebaseFirestore.instance.collection('User').doc(widget.userId).get();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return FutureBuilder<DocumentSnapshot>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              const CircleAvatar(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                lang.translate('loading'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          );
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Row(
            children: [
              const CircleAvatar(child: Icon(Icons.error)),
              const SizedBox(width: 8),
              Text(
                lang.translate('unknown'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        String avatarUrl = userData['ProfilePicture'] ?? '';
        String displayName = "${userData['FirstName']} ${userData['LastName']}";
        return Row(
          children: [
            CircleAvatar(
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : const AssetImage('assets/images/content/user.png') as ImageProvider,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                displayName,
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}
