import 'package:flutter/material.dart';
import 'package:rc_rtc_tolotanana/components/operation_chart.dart';
import 'package:rc_rtc_tolotanana/models/edition.dart';
import 'package:rc_rtc_tolotanana/models/patient.dart';
import 'package:rc_rtc_tolotanana/views/pages/add_patient_view.dart';
import 'package:rc_rtc_tolotanana/views/pages/patient_list_view.dart';
import 'package:rc_rtc_tolotanana/views/pages/program_view.dart';
import 'package:rc_rtc_tolotanana/views/widgets/custom_appbar.dart';

import '../../services/database.dart';

class EditionDetailsView extends StatefulWidget {
  final Edition edition;

  const EditionDetailsView({super.key, required this.edition});

  @override
  State<EditionDetailsView> createState() => _EditionDetailsViewState();
}

class _EditionDetailsViewState extends State<EditionDetailsView> {
  List<Patient> patients = [];

  @override
  void initState() {
    getPatients();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            titleString: 'Statistiques',
            buttonTitle: 'Ajouter',
            callback: addNewItem),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
              children: [
                Text(
                  '${widget.edition.year} - ${widget.edition.city}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer()
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                    child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PatientListView(
                              edition: widget.edition,
                            )));
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nombre de patients',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            FutureBuilder(
                                future: DatabaseClient()
                                    .getNumberOfPatients(widget.edition.id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox(height: 15, width: 15, child: CircularProgressIndicator());
                                  } else if (snapshot.hasData) {
                                    return 
                                    Text(
                                      snapshot.data.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                }),
                            const Text('patients total'),
                            FutureBuilder(
                                future: DatabaseClient()
                                    .getPatientPerSex(widget.edition.id),
                                builder: (context, snapshot) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          const Text('Hommes'),
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting)
                                            const CircularProgressIndicator()
                                          else if (snapshot.hasData)
                                            Text(' ${getPerSexNumber(snapshot, 0)}')
                                          else
                                            const CircularProgressIndicator()
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          const Text('Femmes'),
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting)
                                            const CircularProgressIndicator()
                                          else if (snapshot.hasData)
                                            Text(' ${getPerSexNumber(snapshot, 1)}')
                                          else
                                            const CircularProgressIndicator()
                                        ],
                                      ),
                                    ],
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
                Expanded(
                  child: FutureBuilder(
                      future: DatabaseClient()
                          .getPatientPerObservation(widget.edition.id),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 6,
                              width: double.infinity,
                              child: Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle),
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting)
                                        const CircularProgressIndicator()
                                      else if (snapshot.hasData)
                                        Text(
                                            getPerObservationNumber(snapshot, 1)
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.green[700],
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold))
                                      else
                                        const CircularProgressIndicator(),
                                      const Text('Aptes à operer')
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 6,
                              width: double.infinity,
                              child: Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.warning),
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting)
                                        const CircularProgressIndicator()
                                      else if (snapshot.hasData)
                                        Text(
                                            getPerObservationNumber(snapshot, 0)
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.red[600],
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold))
                                      else
                                        const CircularProgressIndicator(),
                                      const Text('Inaptes pour operation')
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      }),
                )
              ],
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProgramPage(
                          edition: widget.edition,
                        )));
              },
              child: const Card(
                elevation: 2,
                child: SizedBox(
                  height: 100,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 50),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Programme', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Row(children: [
              Text(
                'Ages',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              Spacer()
            ]),
            const SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.5),
                  border: Border.all(color: Colors.grey)),
              height: 75,
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Minimum'),
                subtitle: const Text('Age le plus jeune'),
                trailing: FutureBuilder(
                    future: DatabaseClient().getMinAge(widget.edition.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasData) {
                        return Text(
                          snapshot.data.toString(),
                          style: const TextStyle(fontSize: 24),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    }),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.5),
                    border: Border.all(color: Colors.grey)),
                height: 75,
                child: ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Moyenne'),
                    subtitle: const Text('La moyenne d\'age'),
                    trailing: FutureBuilder(
                        future:
                            DatabaseClient().getAverageAge(widget.edition.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasData) {
                            return Text(
                              snapshot.data.toString(),
                              style: const TextStyle(fontSize: 24),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        }))),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.5),
                  border: Border.all(color: Colors.grey)),
              height: 75,
              child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Maximum'),
                  subtitle: const Text('Age le plus vieux'),
                  trailing: FutureBuilder(
                      future: DatabaseClient().getMaxAge(widget.edition.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasData) {
                          return Text(
                            snapshot.data.toString(),
                            style: const TextStyle(fontSize: 24),
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      })),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Text(
                  'Opérations',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Voir tout',
                      style: TextStyle(color: Colors.blueAccent),
                    )),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const OperationChart()
          ]),
        )));
  }

  addNewItem() {
    final next = AddPatientView(edition: widget.edition);
    Navigator.push(context, MaterialPageRoute(builder: (context) => next))
        .then((value) => getPatients());
  }

  getPatients() async {
    DatabaseClient().patientFromEdition(widget.edition.id).then((patients) {
      setState(() {
        this.patients = patients;
        print('Patients: ${this.patients.length}');
      });
    });
  }

  getPerSexNumber(
      AsyncSnapshot<List<Map<String, dynamic>>> snapshot, int sexValue) {
    int count = 0;

    if (snapshot.data == null) return count;
    for (final map in snapshot.data!) {
      if (map['sex'] == sexValue) {
        count = map['COUNT(*)'];
        break;
      }
    }
    return count;
  }

  getPerObservationNumber(AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
      int observationValue) {
    int count = 0;

    for (final map in snapshot.data!) {
      if (map['observation'] == observationValue) {
        count = map['COUNT(*)'];
        break;
      }
    }
    return count;
  }
}
