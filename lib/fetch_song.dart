import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

OnAudioQuery onAudioQuery = OnAudioQuery();

Future<Uint8List?> art({required int id}) async {
  return await onAudioQuery.queryArtwork(id, ArtworkType.AUDIO, quality: 100);
}

class FetchSongs {
  static Future<List<MediaItem>> execute() async {
    List<MediaItem> items = [];

    await accessStorage().then(
          (value) async {

        final songs = await onAudioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,);


        // looping and converting all songs to MediaItem.
        for (SongModel song in songs) {
          if (song.duration! != 0) {
            List<int> bytes = [];
            Uint8List? uint8list;
            if (song.isMusic == true) {
              //   Retrieve artwork for the song.
              uint8list = await art(id: song.id);
              if (uint8list != null) {
                bytes = uint8list.toList();
              }
              items.add(
                MediaItem(
                    id: song.uri!,
                    title: song.displayName,
                    duration: Duration(milliseconds: song.duration!),
                    artUri: bytes.isNotEmpty ? Uri.dataFromBytes(bytes) : null),
              );
            }


          }

        }
      },
    );

    return items;
  }
}

// Convert uri to image
Future<Uint8List?> toImage(Uri uri) async {
  return base64.decode(uri.data!.toString().split(',').last);
}

Future<void> accessStorage() async {

  PermissionStatus status;
  if (Platform.isAndroid) {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
    if ((info.version.sdkInt) >= 33) {
      status = await Permission.manageExternalStorage.request();
    } else {
      status = await Permission.storage.request();
    }
  } else {
    status = await Permission.storage.request();
  }



  switch (status) {
    case PermissionStatus.denied:
      accessStorage();
      break;
    case PermissionStatus.granted:
      // permission granted.
      break;
    case PermissionStatus.restricted:
      break ;
    case PermissionStatus.limited:
      break ;
    case PermissionStatus.permanentlyDenied:
      openAppSettings();
      break;
    case PermissionStatus.provisional:
      break;
  }
    // await Permission.storage.status.isGranted.then(
    //   (isGranted) async {
    //     if (isGranted == false) {
    //       final permissionStatus = await Permission.storage.request();
    //       if (permissionStatus == PermissionStatus.permanentlyDenied) {
    //         openAppSettings();
    //       }
    //     }
    //   },
    // );
}

