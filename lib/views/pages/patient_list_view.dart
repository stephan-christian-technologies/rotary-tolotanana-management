// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:rc_rtc_tolotanana/models/edition.dart';
import 'package:rc_rtc_tolotanana/models/patient.dart';
import 'package:rc_rtc_tolotanana/services/database.dart';
import 'package:rc_rtc_tolotanana/utils/csv_utils.dart';

class PatientListView extends StatefulWidget {
  const PatientListView({
    Key? key,
    required this.edition,
  }) : super(key: key);
  final Edition edition;

  @override
  State<PatientListView> createState() => _PatientListViewState();
}

class _PatientListViewState extends State<PatientListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          //app bar with search icon, on press search icon, show search bar
          AppBar(
        title: const Text('Liste des patients'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // showSearch<String>(
              //   context: context,
              //   delegate: PatientSearchDelegate(),
              // );
            },
          ),
          //export data to csv
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () async {
              await patientsByEdtionToCsv(widget.edition, context);
            },
          ),
        ],
      ),
      body: FutureBuilder(
          future: DatabaseClient().getPatientsByEditionId(widget.edition.id),
          builder:
              (BuildContext context, AsyncSnapshot<List<Patient>> snapshot) {
            if (snapshot.hasError) {
              return const Center(
                  child: Text('Erreur de chargement des données'));
            } else if (snapshot.hasData) {
              return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  Patient patient = snapshot.data![index];
                  return ListTile(
                    title: Text(patient.lastname),
                    subtitle: Text(patient.firstname ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        // await DatabaseClient().deletePatient(patient.id);
                        setState(() {});
                      },
                    ),
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
