// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:open_filex/open_filex.dart';
import 'package:rc_rtc_tolotanana/models/patient.dart';
import 'package:rc_rtc_tolotanana/services/database.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:share_plus/share_plus.dart';

patientsByEdtionToCsv(String editionId, BuildContext context) async {
  //get patients by edition id from database then convert to csv
  List<Patient> patients =
      await DatabaseClient().getPatientsByEditionId(editionId);
  //convert patients to csv
  await savePatientsToCSV(patients, context);
}

Future<void> savePatientsToCSV(
    List<Patient> patients, BuildContext context) async {
  List<List<dynamic>> csvData = [];

  // Add CSV header
  csvData.add([
    'id',
    'lastname',
    'firstname',
    'age',
    'sex',
    'anesthesiaType',
    'telephone',
    'observation',
    'comment',
    'address',
    'birthDate',
  ]);

  int count = 0;
  // Add patient data
  for (Patient patient in patients) {
    count++;
    csvData.add([
      count.toString(),
      patient.lastname,
      patient.firstname ?? '',
      patient.age,
      patient.sex.toString().split('.').last, // Convert enum to string
      patient.anesthesiaType.split('.').last,
      patient.telephone,
      patient.observation,
      patient.comment ?? '',
      patient.address ?? '',
      patient.birthDate?.toIso8601String() ?? '',
    ]);
  }

  // Create a CSV string
  String csvString = const ListToCsvConverter().convert(csvData);
  print(csvString);

  // Get the document directory
  final directory = await getExternalStorageDirectory();
  final path = '${directory?.path}/patients.csv';

  // Write the CSV string to a file
  await File(path).writeAsString(csvString);

  // Show a dialog to the user
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Exportation terminée'),
        content: Text('Les données ont été exportées dans le fichier $path'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          // open the file
          TextButton(
            child: const Text('Ouvrir'),
            onPressed: () async {
              print('Opening $path...');
              await OpenFilex.open(path);
            },
          ),
          // share the file
          TextButton(
            child: const Text('Partager'),
            onPressed: () async {
              print('Sharing $path...');
              final result = await Share.shareFiles([path]);
            },
          ),
        ],
      );
    },
  );
}
