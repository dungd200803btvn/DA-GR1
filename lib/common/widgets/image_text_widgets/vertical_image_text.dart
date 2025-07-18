import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helper/helper_function.dart';

class TVerticalImageText extends StatelessWidget {
  const TVerticalImageText({
    Key? key,
    required this.title,
    this.textColor = Colors.white,
    this.onTap,
    this.backgroundColor,
    required this.url,
  }) : super(key: key);

  final String title;
  final String url;
  final Color textColor;
  final Color? backgroundColor;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hình tròn hiển thị hình ảnh từ Unsplash
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor ?? Colors.grey[300],
              ),
              child: ClipOval(
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Container chứa text với chiều cao cố định để tránh overflow
            Container(
              width: 85,
              height: 44,
              alignment: Alignment.center,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: textColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}