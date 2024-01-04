// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:rc_rtc_tolotanana/models/edition.dart';
import 'package:rc_rtc_tolotanana/models/patient.dart';
import 'package:rc_rtc_tolotanana/services/database.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

Future<void> patientsByEditionToCsv(
    Edition edition, BuildContext context) async {
  final patients = await DatabaseClient().getPatientsByEditionId(edition.id);
  await savePatientsToCsv(patients, context, edition);
}

Future<void> savePatientsToCsv(
    List<Patient> patients, BuildContext context, Edition edition) async {
  final csvData = <List<dynamic>>[];

  // Add CSV header
  csvData.add([
    'id',
    'lastname',
    'firstname',
    'age',
    'sex',
    'operation',
    'anesthesiaType',
    'telephone',
    'observation',
    'comment',
    'address',
    'birthDate',
  ]);

  int count = 0;
  // Add patient data
  for (final patient in patients) {
    count++;

    final operations =
        await DatabaseClient().getPatientOperationByPatientId(patient.id);
    String operation = '';

    if (operations.isNotEmpty) {
      // Join operations with '-'
      operation = operations
          .map((op) => op['name'].toString().split('.').last)
          .join('-');
    }

    csvData.add([
      count.toString(),
      patient.lastname,
      patient.firstname ?? '-',
      patient.age,
      patient.sex.toString().split('.').last == '0'
          ? 'H'
          : 'F', // Convert enum to string
      operation,
      patient.anesthesiaType.split('.').last,
      patient.telephone,
      patient.observation == 1 ? 'Apte' : 'Inapte',
      patient.comment ?? '-',
      patient.address ?? '-',
      patient.birthDate?.toIso8601String().split('T').first,
    ]);
  }

  // Create a CSV string
  final csvString = const ListToCsvConverter().convert(csvData);
  print(csvString);

  // Get the document directory
  final directory = await getExternalStorageDirectory();
  final path =
      '${directory?.path}/patients_${edition.city}_${edition.year}.csv';

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
          // Open the file
          TextButton(
            child: const Text('Ouvrir'),
            onPressed: () async {
              print('Opening $path...');
              await OpenFilex.open(path);
            },
          ),
          // Share the file
          TextButton(
            child: const Text('Partager'),
            onPressed: () async {
              print('Sharing $path...');
            },
          ),
        ],
      );
    },
  );
}
