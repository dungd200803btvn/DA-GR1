import 'package:flutter/cupertino.dart';
import '../../../../l10n/app_localizations.dart';

enum SortOption {
  name,
  higherPrice,
  lowerPrice,
  sale,
  newest,
  popularity
}
extension SortOptionExtension on SortOption {
  String getLabel(BuildContext context) {
    final lang = AppLocalizations.of(context);
    switch (this) {
      case SortOption.name:
        return lang.translate('name');
      case SortOption.higherPrice:
        return lang.translate('higher_price');
      case SortOption.lowerPrice:
        return lang.translate('lower_price');
      case SortOption.sale:
        return lang.translate('sale');
      case SortOption.newest:
        return lang.translate('newest');
      case SortOption.popularity:
        return lang.translate('popularity');
    }
  }
}
