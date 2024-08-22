import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:myplayer/my_audio_controller.dart';
import 'package:myplayer/song_widget.dart';

import '../fetch_song.dart';

class HomePage extends StatefulWidget {
  final MyAudioController myAudioController;

  const HomePage({super.key, required this.myAudioController});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MediaItem> songs = [];

  @override
  void initState() {
    //Retrieve the songs from the fetch songs.
    // fetchSongs();
    FetchSongs.execute().then(
      (songList) {
        setState(() {
          songs = songList;
        });
        // Initialise songs in the audio handler.
        widget.myAudioController.initSongs(songs: songList);
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("M Play"),
      ),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          MediaItem mediaItem = songs[index];
          return SongWidget(
              myAudioController: widget.myAudioController,
              mediaItem: mediaItem,
              index: index);
        },
      ),
    );
  }
}
