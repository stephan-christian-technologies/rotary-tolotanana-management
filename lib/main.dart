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

  final ios = defaultTargetPlatform == TargetPlatform.iOS;
  var app_secret = ios ? '' : "2188eb3f-c4e4-43f5-ba29-de9e84aa52e8";
  await AppCenter.start(secret: app_secret);

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
