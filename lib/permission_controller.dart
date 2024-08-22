
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionSection {
  getDeviceSongs,
  permissionDeny,
  permissionDenyPermanent,
  deviceSongsFetched
}

class PermissionController extends ChangeNotifier {
  PermissionSection _permissionSection = PermissionSection.getDeviceSongs;
  final audioQuery = OnAudioQuery();


  PermissionSection get permissionSection => _permissionSection;

  set permissionSection(PermissionSection value) {
    _permissionSection = value;
    notifyListeners();
  }

  late List<SongModel> songList;

  Future<bool> askPermission() async {
    final storagePermission = await Permission.storage.request();
    if (storagePermission.isGranted) {
      // permissionSection = PermissionSection.deviceSongsFetched;
      return true;
    } else if (storagePermission.isPermanentlyDenied) {
      permissionSection = PermissionSection.permissionDenyPermanent;
    } else if (storagePermission.isDenied) {
      permissionSection = PermissionSection.permissionDeny;
    }
    return false;
  }

  Future<void> fetchSongs() async {
    final songs = await audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    songList = songs;
    permissionSection = PermissionSection.deviceSongsFetched;
  }
}

