import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:myplayer/fetch_song.dart';
import 'package:myplayer/my_audio_controller.dart';
import 'package:myplayer/pages/player_page.dart';

class SongWidget extends StatelessWidget {
  final MyAudioController myAudioController;
  final MediaItem mediaItem;
  final int index;

  const SongWidget(
      {super.key,
      required this.myAudioController,
      required this.mediaItem,
      required this.index});



  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: myAudioController.mediaItem,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return DecoratedBox(
            decoration: BoxDecoration (
              color: snapshot.data == mediaItem ? Colors.blue.shade500 : null,
            ),
            child: ListTile(
              title: Text(mediaItem.title,maxLines: 1,overflow: TextOverflow.ellipsis,),
              subtitle: Text(getAudioDuration()),
              leading: mediaItem.artUri ==  null ? Container(
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(8)
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.music_note_outlined,),
                ),
              ) :
                  FutureBuilder(future: toImage(mediaItem.artUri!),
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                          return Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.blue[700]
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: FadeInImage(
                                image: MemoryImage(snapshot.data!),
                                placeholder: const AssetImage("assets/placeholder.jpg"),
                              ),
                            ),
                          );
                        }else {
                          return const SizedBox.shrink();
                        }
                      },)
              ,
              onTap: () {
                if(snapshot.data != mediaItem ) {
                  myAudioController.skipToQueueItem(index);
                }
                Get.to(PlayerPage(
                  myAudioController: myAudioController
                ),transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 500));
              },
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );

  }

  String getAudioDuration() {
    var duration = mediaItem.duration;
    String h = duration!.inHours.toString().padLeft(2, '0');
    String m = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    String finalDur = "";
    if (h == '00') {
      finalDur = '$m:$s';
      if (m == '00') finalDur = '00:$s';
    } else {
      finalDur = '$h:$m:$s';
    }
    return finalDur;
  }
}
