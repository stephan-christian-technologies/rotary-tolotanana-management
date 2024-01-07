// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:rc_rtc_tolotanana/models/edition.dart';
import 'package:rc_rtc_tolotanana/models/patient.dart';
import 'package:rc_rtc_tolotanana/services/database.dart';
import 'package:rc_rtc_tolotanana/utils/csv_utils.dart';
import 'package:rc_rtc_tolotanana/views/widgets/add_textfield.dart';

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
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          //app bar with search icon, on press search icon, show search bar
          AppBar(
        title: const Text('Liste des patients'),
        actions: <Widget>[
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un patient',
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  labelText: 'Rechercher un patient',
                  suffixIcon: IconButton(
                    icon: _searchController.text.isEmpty
                        ? const Icon(Icons.search)
                        : const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                ),
                onChanged: (String query) {
                  setState(() {});
                },
              )),
          Container(
              margin: const EdgeInsets.only(top: 100),
              child: patientListWidget()),
        ],
      ),
    );
  }

  FutureBuilder<List<Patient>> patientListWidget() {
    final query = _searchController.text;
    return FutureBuilder(
        future: query.isNotEmpty
            ? searchPatient(query)
            : DatabaseClient().getPatientsByEditionId(widget.edition.id),
        builder: (BuildContext context, AsyncSnapshot<List<Patient>> snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text('Erreur de chargement des données'));
          } else if (snapshot.hasData) {
            return (snapshot.data!.isEmpty && query.isNotEmpty)
                ? Center(child: Text('Aucun résultat trouvé pour "$query"'))
                : ListView.separated(
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemBuilder: (BuildContext context, int index) {
                      Patient patient = snapshot.data![index];

                      return ListTile(
                        leading: Text(formatFolderId(patient.folderId),
                            style: TextStyle(
                                fontSize: 20,
                                color: patient.sex == 0
                                    ? Colors.blue[800]
                                    : Colors.pink[800])),
                        title: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: patient.observation == 1
                                    ? Colors.green[500]
                                    : Colors.red[500],
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.55,
                              child: Text(
                                '${patient.lastname} ${patient.firstname ?? ''} - ${patient.age} ans',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
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
                                  return Row(
                                    children: [
                                      Text(snapshot.data!),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Center(
                                          child: Text(
                                            patient.anesthesiaType
                                                .toString()
                                                .split('.')
                                                .last
                                                .toUpperCase(),
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return const Text('Chargement...');
                                }
                              },
                            ),
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
        });
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

  String formatFolderId(int folderId) {
    String folderIdString = folderId.toString();
    if (folderIdString.length == 1) {
      folderIdString = '00$folderIdString';
    } else if (folderIdString.length == 2) {
      folderIdString = '0$folderIdString';
    }
    return folderIdString;
  }

  Future<List<Patient>> searchPatient(String query) async {
    List<Patient> patients =
        await DatabaseClient().getPatientsByEditionId(widget.edition.id);
    List<Patient> results = [];
    for (Patient patient in patients) {
      final operations = await getOperations(patient.id);
      if (patient.lastname.toLowerCase().contains(query.toLowerCase()) ||
          patient.firstname!.toLowerCase().contains(query.toLowerCase()) ||
          patient.folderId.toString().contains(query) ||
          patient.anesthesiaType
              .toString()
              .split('.')
              .last
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          operations.toLowerCase().contains(query)) {
        results.add(patient);
      }
    }
    return results;
  }
}
