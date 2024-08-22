import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';

class MyAudioController extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  // final audioQuery = OnAudioQuery();
  // RxList<SongModel> songs = <SongModel>[].obs;

  final audioPlayer = AudioPlayer();

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return ProgressiveAudioSource(Uri.parse(mediaItem.id));
  }

  void _listenForCurrentSongIndexChanges() {
    audioPlayer.currentIndexStream.listen((index) {

      print('current song index : $index ');


      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      mediaItem.add(
          playlist[index]); // to broadcast the current MediaItem to the Notification UI

    },);
  }

  // Broadcast the current Playback state from the PlaybackEvent accordingly.

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        audioPlayer.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[audioPlayer.processingState]!,
      playing: audioPlayer.playing,
      updatePosition: audioPlayer.position,
      bufferedPosition: audioPlayer.bufferedPosition,
      speed: audioPlayer.speed,
      queueIndex: event.currentIndex,
    ));

  }

  // Initialize the songs and setup the audioPlayer
  Future<void> initSongs({required List<MediaItem> songs}) async {
    // Listen for playback event and broadcast the playback state.
    audioPlayer.playbackEventStream.listen(_broadcastState);

    audioPlayer.positionStream.listen((event) {
    },);



    // create a list of audio sources from the songs provided.
    final audioSource = songs.map((mediaItem) => _createAudioSource(mediaItem),);

    await audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: audioSource.toList()));

    // Add all the songs to queue.
    final newQueue = queue.value..addAll(songs);
    queue.add(newQueue);

    _listenForCurrentSongIndexChanges();

    audioPlayer.processingStateStream.listen((state) {
      if(state == ProcessingState.completed) skipToNext();

    },);
  }

  @override
  Future<void> play() async => audioPlayer.play();

  @override
  Future<void> pause() async => audioPlayer.pause();

  @override
  Future<void> seek(Duration position) async => audioPlayer.seek(position);

  @override
  Future<void> skipToNext() async => audioPlayer.seekToNext();

  @override
  Future<void> skipToPrevious() async => audioPlayer.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    await audioPlayer.seek(Duration.zero, index: index);
    play();
  }



  playAudio({required String audioPath}) {
    audioPlayer.setUrl(audioPath);
    audioPlayer.play();
  }
}
