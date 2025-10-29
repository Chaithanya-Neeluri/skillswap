// video_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../core/theme/app_text_styles.dart';

class VideoTile extends StatelessWidget {
  final RTCVideoRenderer renderer;
  final String label;
  final bool isLocal;
  final BoxFit fit;

  const VideoTile({
    super.key,
    required this.renderer,
    this.label = '',
    this.isLocal = false,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: RTCVideoView(renderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
          ),
          if (label.isNotEmpty)
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                child: Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
