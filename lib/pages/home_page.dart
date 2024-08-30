import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:myplayer/my_audio_controller.dart';
import 'package:myplayer/song_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../fetch_song.dart';

class HomePage extends StatefulWidget {
  final MyAudioController myAudioController;

  const HomePage({super.key, required this.myAudioController});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<MediaItem> songs = [];
  int? permissionStatus = null;
  late PermissionStatus status;
  bool fetchingSongs = true;

  @override
  void initState() {
    super.initState();
    //Retrieve the songs from the fetch songs.
    WidgetsBinding.instance.addObserver(this);
    checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkPermission();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> checkPermission() async {
    print('Checking permission....');
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
      if ((info.version.sdkInt) >= 33) {
        status = await Permission.audio.status;
      } else {
        status = await Permission.storage.status;
      }
    } else {
      status = await Permission.storage.status;
    }

    switch (status) {
      case PermissionStatus.denied:
        permissionStatus = 0;
        break;
      case PermissionStatus.granted:
        // permission granted.
        permissionStatus = 1;
        print('Checking permission done.');
        break;
      case PermissionStatus.permanentlyDenied:
        permissionStatus = 2;
        break;
      case PermissionStatus.restricted:
      // TODO: Handle this case.
      case PermissionStatus.limited:
      // TODO: Handle this case.
      case PermissionStatus.provisional:
      // TODO: Handle this case.
    }

    setState(() {

    });
    

    if (permissionStatus == 1) {
      setState(() {
        FetchSongs.execute().then(
          (songList) {
            setState(() {
              fetchingSongs = false;
              songs = songList;
            });
            // Initialise songs in the audio handler.
            widget.myAudioController.initSongs(songs: songList);
          },
        ).catchError((error) {
          print('Something went wrong! : $error');
        });
        // permissionStatus = true;
      });
    }

    // else if (permissionStatus == 2) {
    //   setState(() {
    //     permissionStatus = false;
    //   });
    // } else {
    //   setState(() {
    //     permissionStatus = false;
    //   });
    // }
  }

  Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
      if ((info.version.sdkInt) >= 33) {
        status = await Permission.audio.request();
      } else {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.storage.request();
    }

    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("M Play"),
        ),
        body: permissionStatus == 1 ? _songsWidget() : _permissionWidget());
  }

  Widget _songsWidget() {
    return fetchingSongs
        ? Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(
                height: 16,
              ),
              Text(
                "Loading Songs",
                style: TextStyle(fontSize: 24),
              )
            ],
          ))
        : songs.length == 0
            ? Center(
                child: Text(
                'No songs found!',
                style: TextStyle(fontSize: 18),
              ))
            : ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  MediaItem mediaItem = songs[index];
                  return SongWidget(
                      myAudioController: widget.myAudioController,
                      mediaItem: mediaItem,
                      index: index);
                },
              );
  }

  Widget _permissionWidget() {
    // bool permanentDenied = status.isPermanentlyDenied;
    if (permissionStatus == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title Text
            Text(
              'Permission Required',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            SizedBox(
              height: 24,
            ),

            //  Description Text
            permissionStatus == 0
                ? Text(
                    'Please allow the permission to access device songs.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )
                : Text(
                    'Permission is denied permanently, allow permission from the app settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),

            SizedBox(
              height: 24,
            ),

            ElevatedButton(
                onPressed: () {
                  if (permissionStatus == 2) {
                    openAppSettings();
                  } else {
                    requestPermission();
                  }
                },
                child: permissionStatus == 2
                    ? Text("Open Settings")
                    : Text('Allow Permission'))
          ],
        ),
      ),
    );
  }
}
