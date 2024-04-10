// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:rc_rtc_tolotanana/models/patient.dart';
import 'package:rc_rtc_tolotanana/services/database.dart';
import 'package:rc_rtc_tolotanana/utils/csv_utils.dart';
import 'package:rc_rtc_tolotanana/utils/utils.dart';
import 'package:rc_rtc_tolotanana/views/pages/patient_details_view.dart';
import 'package:sqflite/sqflite.dart';

class ProgramDayView extends StatefulWidget {
  const ProgramDayView({
    Key? key,
    required this.day,
  }) : super(key: key);
  final int day;
  @override
  State<ProgramDayView> createState() => _ProgramDayViewState();
}

class _ProgramDayViewState extends State<ProgramDayView> {
  late TextEditingController _searchController;
  bool _isSelecting = false;
  bool _allSelected = false;
  List<String> _selectedIds = [];
  List<Patient> _patients = [];

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        child: const Icon(Icons.refresh),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_isSelecting
            ? '${_selectedIds.length} séléctionné(s)'
            : '${getStatusDetails(widget.day)['day']} : ${_patients.length} patients'),
        actions: <Widget>[
          if (!_isSelecting)
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: () async {
                // await patientsByEditionToCsv(widget.edition, context);
              },
            ),
          if (_isSelecting)
            TextButton(
              onPressed: () {
                setState(() {
                  _allSelected = !_allSelected;
                  _selectedIds = [];
                  if (_allSelected) {
                    _selectedIds.addAll(_patients.map((patient) => patient.id));
                  }
                });
              },
              child: Text(
                (_allSelected && _selectedIds.isNotEmpty)
                    ? 'Désélectionner tout'
                    : 'Sélectionner tout',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          if (_isSelecting)
            TextButton(
              onPressed: () {
                setState(() {
                  _isSelecting = false;
                  _selectedIds = [];
                });
              },
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.black),
              ),
            ),
          if (_isSelecting)
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Actions"),
                          content: Column(children: [
                            TextButton(
                                onPressed: () {
                                  for (String id in _selectedIds) {
                                    DatabaseClient().deletePatient(id);
                                  }
                                  setState(() {});
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Supprimer')),
                            TextButton(
                                onPressed: () async {
                                  await groupUpdateStatus(context, 1);
                                },
                                child: const Text('Lundi')),
                            TextButton(
                                onPressed: () async {
                                  await groupUpdateStatus(context, 2);
                                },
                                child: const Text('Mardi')),
                            TextButton(
                                onPressed: () async {
                                  await groupUpdateStatus(context, 3);
                                },
                                child: const Text('Mercredi')),
                            TextButton(
                                onPressed: () async {
                                  await groupUpdateStatus(context, 4);
                                },
                                child: const Text('Jeudi')),
                            TextButton(
                                onPressed: () async {
                                  await groupUpdateStatus(context, 5);
                                },
                                child: const Text('Vendredi')),
                          ]),
                        );
                      });
                },
                icon: const Icon(Icons.more_vert))
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un patient',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
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
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 90),
            child: patientListWidget(),
          ),
        ],
      ),
    );
  }

  Future<void> groupUpdateStatus(BuildContext context, int status) async {
    for (String id in _selectedIds) {
      final p = await DatabaseClient().getPatient(id);
      final map = p.toMap();
      map['status'] = status;
      await DatabaseClient().updatePatient(Patient.fromMap(map));
    }
    setState(() {
      _isSelecting = false;
      _selectedIds = [];
    });
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  FutureBuilder<List<Patient>> patientListWidget() {
    final query = _searchController.text;
    setState(() {});
    return FutureBuilder<List<Patient>>(
      future: query.isNotEmpty
          ? searchPatient(query)
          : DatabaseClient().getPatientByStatus(widget.day),
      builder: (BuildContext context, AsyncSnapshot<List<Patient>> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erreur de chargement des données'));
        } else if (snapshot.hasData) {
          final patients = snapshot.data!;
          updatePatientList(patients);
          return (patients.isEmpty && query.isNotEmpty)
              ? Center(child: Text('Aucun résultat trouvé pour "$query"'))
              : ListView.separated(
                  itemCount: patients.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    final patient = patients[index];
                    return Slidable(
                      key: Key(patient.id),
                      direction: Axis.horizontal,
                      useTextDirection: false,
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              updateStatus(1, patient);
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            label: '1',
                          ),
                          SlidableAction(
                            onPressed: (context) {
                              updateStatus(2, patient);
                            },
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            label: '2',
                          ),
                          SlidableAction(
                            onPressed: (context) {
                              updateStatus(3, patient);
                            },
                            backgroundColor: Colors.yellow,
                            foregroundColor: Colors.white,
                            label: '3',
                          ),
                          SlidableAction(
                              onPressed: (context) {
                                updateStatus(4, patient);
                              },
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              label: '4'),
                          SlidableAction(
                            onPressed: (context) {
                              updateStatus(5, patient);
                            },
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            label: '5',
                          ),
                          SlidableAction(
                            onPressed: (context) {
                              updateStatus(6, patient);
                            },
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            label: '6',
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  PatientDetailsPage(patient: patient)));
                        },
                        onLongPress: () {
                          setState(() {
                            _isSelecting = true;
                            _selectedIds.add(patient.id);
                          });
                        },
                        child: ListTile(
                          leading: Text(
                            formatFolderId(patient.folderId),
                            style: TextStyle(
                              fontSize: 20,
                              color: patient.sex == 0
                                  ? Colors.blue[800]
                                  : Colors.pink[800],
                            ),
                          ),
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
                              FutureBuilder<String>(
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
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        patient.anesthesiaType
                                            .toString()
                                            .split('.')
                                            .last
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  patient.status != null
                                      ? Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: getStatusDetails(
                                                patient.status!)['color'],
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              getStatusDetails(
                                                  patient.status!)['day'],
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Non programmé',
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ],
                          ),
                          trailing: _isSelecting
                              ? Checkbox(
                                  value: _selectedIds.contains(patient.id),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedIds.add(patient.id);
                                      } else {
                                        _selectedIds.remove(patient.id);
                                      }
                                    });
                                  },
                                )
                              : const Icon(Icons.chevron_right),
                        ),
                      ),
                    );
                  },
                );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void updatePatientList(List<Patient> patients) {
    _patients = patients;
  }

  Future<String> getOperations(String id) async {
    final map = await DatabaseClient().getPatientOperationByPatientId(id);
    final operations = map.map<String>((map) {
      return map['name'].toString().split('.').last.toUpperCase();
    }).join(', ');
    return operations;
  }

  String formatFolderId(int folderId) {
    String folderIdString = folderId.toString().padLeft(3, '0');
    return folderIdString;
  }

  Future<List<Patient>> searchPatient(String query) async {
    List<Patient> patients =
        await DatabaseClient().getPatientByStatus(widget.day);
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
          operations.toLowerCase().contains(query.toLowerCase()) ||
          getStatusDetails(patient.status)['day']
              .toLowerCase()
              .contains(query.toLowerCase())) {
        results.add(patient);
      }
    }
    return results;
  }

  updateStatus(int status, Patient patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text('Voulez-vous vraiment modifier le statut en $status ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                var patientMap = patient.toMap();
                patientMap['status'] = status;
                try {
                  await DatabaseClient()
                      .updatePatient(Patient.fromMap(patientMap));
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Erreur'),
                          content: Text(e.toString()),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      });
                }
                setState(() {});
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}
