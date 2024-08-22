import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:myplayer/my_audio_controller.dart';

class ControlsWidget extends StatelessWidget {
  final MyAudioController audioController;
  final MediaItem mediaItem;
  const ControlsWidget({super.key,required this.mediaItem, required this.audioController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: audioController.playbackState,
        builder: (context, playbackSnap) {
          if( playbackSnap.hasData){
            bool isPlaying= playbackSnap.data!.playing;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filledTonal(onPressed: () {
                  audioController.skipToPrevious();
                }, icon: Icon(Icons.skip_previous)),
                IconButton.filledTonal(onPressed: () {
                  if( isPlaying) {
                    audioController.pause();
                  }else {
                    audioController.play();
                  }
                }, icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,size: 48,),),
                IconButton.filledTonal(onPressed: () {
                  audioController.skipToNext();
                }, icon: Icon(Icons.skip_next)),
              ],
            );
          }
          return SizedBox.shrink();
        },);
  }
}
