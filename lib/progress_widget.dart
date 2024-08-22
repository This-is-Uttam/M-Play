import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:myplayer/my_audio_controller.dart';

class ProgressWidget extends StatelessWidget {
  final MyAudioController audioController;
  final MediaItem mediaItem;

  const ProgressWidget(
      {super.key, required this.mediaItem, required this.audioController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: AudioService.position,
      builder: (context, positionSnapshot) {
        if (positionSnapshot.data != null) {
          return ProgressBar(
            progress: positionSnapshot.data!,
            total: mediaItem.duration!,
            onSeek: (position) => audioController.seek(position),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
