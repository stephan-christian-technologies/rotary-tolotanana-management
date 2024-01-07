import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
      appBar: AppBar(
        title: Text(_isSelecting
            ? '${_selectedIds.length} séléctionné(s)'
            : 'Liste des patients'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () async {
              await patientsByEditionToCsv(widget.edition, context);
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

  FutureBuilder<List<Patient>> patientListWidget() {
    final query = _searchController.text;
    return FutureBuilder<List<Patient>>(
      future: query.isNotEmpty
          ? searchPatient(query)
          : DatabaseClient().getPatientsByEditionId(widget.edition.id),
      builder: (BuildContext context, AsyncSnapshot<List<Patient>> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erreur de chargement des données'));
        } else if (snapshot.hasData) {
          final patients = snapshot.data!;
          _patients = patients;
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
                      endActionPane: const ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: null,
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                          SlidableAction(
                            onPressed: null,
                            backgroundColor: Color(0xFF21B7CA),
                            foregroundColor: Colors.white,
                            icon: Icons.share,
                            label: 'Share',
                          ),
                        ],
                      ),
                      child: GestureDetector(
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
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
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
          operations.toLowerCase().contains(query.toLowerCase())) {
        results.add(patient);
      }
    }
    return results;
  }
}
