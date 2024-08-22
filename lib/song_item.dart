import 'package:myplayer/pages/player_page.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SongItem extends StatelessWidget {
  final SongModel songDetails;
  const SongItem({super.key, required this.songDetails});



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {},
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          bottom: 8,
        ),
        decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            songDetails.displayName,
            style: const TextStyle(
              fontSize: 20,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
