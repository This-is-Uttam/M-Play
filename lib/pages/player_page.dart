import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:myplayer/controls_widget.dart';
import 'package:myplayer/cover_image.dart';
import 'package:myplayer/my_audio_controller.dart';
import 'package:myplayer/progress_widget.dart';

class PlayerPage extends StatefulWidget {
  final MyAudioController myAudioController;

  const PlayerPage({
    super.key,
    required this.myAudioController,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Player Page")),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: StreamBuilder(
          stream: widget.myAudioController.mediaItem,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              MediaItem mItem = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // song cover image
                  CoverImage(mediaItem: mItem),
                  // song title
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,

                    children: [
                      Text(
                        mItem.title,
                        style: TextStyle(fontSize: 20),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // song progress bar
                      ProgressWidget(mediaItem: mItem, audioController: widget.myAudioController,),

                      ControlsWidget(audioController: widget.myAudioController, mediaItem: mItem),

                    ],
                  )
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
