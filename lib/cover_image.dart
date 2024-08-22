import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'fetch_song.dart';

class CoverImage extends StatelessWidget {
  final MediaItem mediaItem;

  const CoverImage({super.key, required this.mediaItem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.width * 0.65,
        width: MediaQuery.of(context).size.width * 0.65,
        decoration: BoxDecoration(
            color: Colors.blue[700], borderRadius: BorderRadius.circular(18)),
        child: mediaItem.artUri == null
            ? const Icon(Icons.music_note_outlined)
            : FutureBuilder(
                future: toImage(mediaItem.artUri!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: FadeInImage(
                        fit: BoxFit.fill,
                        image: MemoryImage(snapshot.data!),
                        placeholder: const AssetImage("assets/placeholder.jpg"),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
      ),
    );
  }
}
