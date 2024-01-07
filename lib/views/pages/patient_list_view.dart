// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:rc_rtc_tolotanana/models/edition.dart';
import 'package:rc_rtc_tolotanana/models/patient.dart';
import 'package:rc_rtc_tolotanana/models/patient_operation.dart';
import 'package:rc_rtc_tolotanana/services/database.dart';
import 'package:rc_rtc_tolotanana/utils/csv_utils.dart';
import 'package:rc_rtc_tolotanana/views/widgets/add_textfield.dart';
import 'package:sqflite/sqflite.dart';

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
              await patientsByEditionToCsv(widget.edition, context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          //search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AddTextfield(
                hint: 'Rechercher...', controller: TextEditingController()),
          ),
          Container(
            margin: const EdgeInsets.only(top: 100),
            child: FutureBuilder(
                future:
                    DatabaseClient().getPatientsByEditionId(widget.edition.id),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Patient>> snapshot) {
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
                          leading: Container(
                              width: 50,
                              height: 30,
                              decoration: BoxDecoration(
                                color: patient.observation == 1
                                    ? Colors.green[200]
                                    : Colors.red[200],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  //circular shape for sex, blue for man, pink for female
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: patient.sex == 0
                                          ? Colors.blue
                                          : Colors.pink,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  Text(patient.folderId.toString()),
                                ],
                              )),
                          title: Text(
                              '${patient.lastname} ${patient.firstname ?? ''} - ${patient.age} ans'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder(
                                future: getOperations(patient.id),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text(
                                        'Erreur de chargement de la liste des opérations');
                                  } else if (snapshot.hasData) {
                                    return Text(snapshot.data!);
                                  } else {
                                    return const Text('Chargement...');
                                  }
                                },
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.medication_liquid_outlined),
                                  const SizedBox(width: 5),
                                  Text(patient.anesthesiaType
                                      .toString()
                                      .split('.')
                                      .last
                                      .toUpperCase()),
                                ],
                              )
                            ],
                          ),
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
          ),
        ],
      ),
    );
  }

  Future<String> getOperations(String id) async {
    final map = await DatabaseClient().getPatientOperationByPatientId(id);
    String operations = '';
    for (Map<String, dynamic> map in map) {
      operations += '${map['name'].toString().split('.').last.toUpperCase()}, ';
    }
    //remove the last ', '
    operations = operations.substring(0, operations.length - 2);
    return operations;
  }
}
