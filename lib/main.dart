import 'dart:async';

import 'package:appcenter_sdk_flutter/appcenter_sdk_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rc_rtc_tolotanana/firebase_options.dart';
import 'package:rc_rtc_tolotanana/services/database.dart';

import 'views/pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // try {
  //   final ios = defaultTargetPlatform == TargetPlatform.iOS;
  //   var appSecret = ios
  //       ? "67026959-a58f-4cc8-86f6-9ed6b6909815"
  //       : "2188eb3f-c4e4-43f5-ba29-de9e84aa52e8";
  //   await AppCenter.start(secret: appSecret);
  //   FlutterError.onError = (final details) async {
  //     await AppCenterCrashes.trackException(
  //       message: details.exception.toString(),
  //       type: details.exception.runtimeType,
  //       stackTrace: details.stack,
  //     );
  //   };
  //   PlatformDispatcher.instance.onError = (error, stack) {
  //     AppCenterCrashes.trackException(
  //       message: error.toString(),
  //       type: error.runtimeType,
  //       stackTrace: stack,
  //     );
  //     return true;
  //   };
  // } on Exception catch (e) {
  //   print(e.toString());
  // }

  DatabaseClient databaseClient = DatabaseClient();

  // Synchroniser toutes les données avec Firebase au démarrage
  await databaseClient.syncAllDataWithFirebase();

  // Définir un Timer pour synchroniser les données toutes les heures
  const Duration syncInterval = Duration(seconds: 60);
  Timer.periodic(syncInterval, (Timer timer) async {
    print("Synchronisation des données avec Firebase");
    await databaseClient.syncAllDataWithFirebase();
    // Vous pouvez également effectuer d'autres actions après la synchronisation...
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tolotanana by RC-RTC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
