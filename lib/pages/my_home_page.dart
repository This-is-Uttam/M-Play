import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myplayer/my_audio_controller.dart';
import 'package:myplayer/permission_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';


import '../song_item.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MyAudioController myAudioController = Get.put(MyAudioController());

  final _controller = PermissionController();

  @override
  void initState() {

    _requestPermissionAndGetSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _controller,
        child: Consumer<PermissionController>(
          builder: (BuildContext context, PermissionController controller,
              Widget? child) {
            Widget widget;

            switch (controller.permissionSection) {
              // case PermissionSection.getDeviceSongs:
              //   widget = GetSongs();
              //   break;
              case PermissionSection.permissionDeny:
                widget = PermissionRequired(
                    permanent: false,
                    onPress: () => _requestPermissionAndGetSongs());
                break;
              case PermissionSection.permissionDenyPermanent:
                widget = PermissionRequired(
                    permanent: true,
                    onPress: () => _requestPermissionAndGetSongs());
                break;
              case PermissionSection.deviceSongsFetched:
                widget = DeviceSongsFetched(songs: controller.songList);
                break;
              case PermissionSection.getDeviceSongs:
                widget = const Center(child: CircularProgressIndicator());
                break;
            }

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Text("My Music Player"),
              ),
              body: widget,
            );
          },
        ));
  }

  Future<void> _requestPermissionAndGetSongs() async {
    final isPermission = await _controller.askPermission();
    if (isPermission) {
      await _controller.fetchSongs();
    } else {
      print("Something went wrong!");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Something went wrong!"),
        action: SnackBarAction(
            label: "Retry", onPressed: _requestPermissionAndGetSongs),
      ));
    }
  }
}

class PermissionRequired extends StatelessWidget {
  final bool permanent;
  final VoidCallback onPress;

  const PermissionRequired(
      {super.key, required this.permanent, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Storage Permission Required!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
              child: permanent
                  ? const Text(
                      "You have denied the permission before, click 'Allow Permission' to allow the storage permission of your system settings.",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    )
                  : const Text(
                      "Allow us to use to device to get songs, click 'Allow Permission' to give permission of your device storage.",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    )),
          ElevatedButton(
              onPressed: permanent ? openAppSettings : onPress,
              child: const Text("Allow Permission")),
        ],
      ),
    );
  }
}

class DeviceSongsFetched extends StatelessWidget {
  final List<SongModel> songs;

  const DeviceSongsFetched({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
            children: songs.map((e) => SongItem(songDetails: e),).toList()

            ),
      ),
    );
  }
}
