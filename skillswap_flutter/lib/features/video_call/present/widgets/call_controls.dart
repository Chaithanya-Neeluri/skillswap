// call_controls.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CallControls extends StatelessWidget {
  final VoidCallback onToggleAudio;
  final VoidCallback onSwitchCamera;
  final VoidCallback onEndCall;
  final bool muted;

  const CallControls({
    super.key,
    required this.onToggleAudio,
    required this.onSwitchCamera,
    required this.onEndCall,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'audio',
            backgroundColor: muted ? Colors.grey : AppColors.surface,
            onPressed: onToggleAudio,
            child: Icon(muted ? Icons.mic_off : Icons.mic, color: AppColors.textPrimary),
          ),
          FloatingActionButton(
            heroTag: 'end',
            backgroundColor: AppColors.error,
            onPressed: onEndCall,
            child: const Icon(Icons.call_end, color: Colors.white),
          ),
          FloatingActionButton(
            heroTag: 'switch',
            backgroundColor: AppColors.surface,
            onPressed: onSwitchCamera,
            child: const Icon(Icons.switch_camera, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
