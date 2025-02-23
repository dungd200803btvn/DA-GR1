import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';

class UserRatingBarIndicator extends StatelessWidget {
  const UserRatingBarIndicator({
    super.key,
    required this.rating,
  });

  final double rating;

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: rating,
      itemSize: 20,
      itemCount: 5,
      unratedColor: DColor.grey,
      itemBuilder: (_, __) => const Icon(Iconsax.star1, color: Colors.amber),
    );
  }
}
