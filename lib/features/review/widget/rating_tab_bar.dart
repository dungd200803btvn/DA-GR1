import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RatingTabBar extends StatelessWidget {
  const RatingTabBar({super.key, required this.rating});
final String rating;
  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        children: [
          Text(rating),
          const SizedBox(width: 4),
          const Icon(Icons.star, color: Colors.amber, size: 16),
        ],
      ),
    );
  }
}
