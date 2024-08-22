import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:myplayer/pages/home_page.dart';

import 'my_audio_controller.dart';

MyAudioController _myAudioController = MyAudioController();

Future<void> main() async {
  // Ensure flutter binding initialised
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise AudioService with MyAudioController as audio handler
  _myAudioController = await AudioService.init(
    builder: () => MyAudioController(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.myplayer.channel.audio',
      androidNotificationChannelName: 'Audio PlaybacK',
      androidNotificationOngoing: true,
    ),
  );

  // Run the application and set preffered orientation to portrait.
  runApp(const MyApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.dark(),
      home: HomePage(myAudioController: _myAudioController),
    );
  }
}
