import 'package:flutter/material.dart';
import 'package:t_store_app/l10n/app_localizations.dart';
import '../../../common/widgets/appbar/appbar.dart';


class FullScreenImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:  TAppBar(
        title: Text(lang.translate('zoom_image',), style: Theme.of(context).textTheme.headlineSmall,),
        showBackArrow: true,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
