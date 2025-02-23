import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onTap;

  const VideoThumbnailWidget({super.key, required this.videoUrl, required this.onTap});

  @override
  _VideoThumbnailWidgetState createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  Uint8List? _thumbnailBytes;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    final uint8List = await VideoThumbnail.thumbnailData(
      video: widget.videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 100,  // Chiều cao thumbnail
      maxWidth: 100,   // Chiều rộng thumbnail
      quality: 75,
    );

    if (mounted) {
      setState(() {
        _thumbnailBytes = uint8List;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Stack(
        children: [
          _thumbnailBytes != null
              ? Image.memory(_thumbnailBytes!, width: 100, height: 100, fit: BoxFit.cover)
              : Container(
            width: 100,
            height: 100,
            color: Colors.black12,
            child: const Center(child: CircularProgressIndicator()),
          ),
          const Positioned.fill(
            child: Center(
              child: Icon(Icons.play_circle_fill, size: 40, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
