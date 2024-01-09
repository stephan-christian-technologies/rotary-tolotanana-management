import 'package:flutter/material.dart';
import 'package:rc_rtc_tolotanana/models/patient.dart';

class PatientDetailsPage extends StatefulWidget {
  const PatientDetailsPage({super.key, required this.patient});
  final Patient patient;

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  late Patient patient;

  @override
  void initState() {
    patient = widget.patient;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Détails du patient'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 20),
                      Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: patient.sex == 0 ? Colors.blue : Colors.pink,
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 70)),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                '${patient.lastname} ${patient.firstname ?? ''}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(
                                'N° ${patient.folderId}    -    ${patient.age} ans')
                          ],
                        ),
                      )
                    ]),
                const SizedBox(height: 10),
                Text(patient.observation.toString() == '1' ? 'Apte' : 'Inapte',
                    style: const TextStyle(fontSize: 20)),
                Card(
                  child: SizedBox(
                      height: 100,
                      child: Center(
                          child: Text(
                              (patient.status.toString() != 'null' &&
                                      patient.observation.toString() == '1')
                                  ? patient.status.toString()
                                  : (patient.status.toString() == 'null' &&
                                          patient.observation.toString() == '1')
                                      ? 'Pas encore programmé'
                                      : 'Pas programmé pour cette mission',
                              style: const TextStyle(fontSize: 20)))),
                ),
                Text('Diagnostic', style: const TextStyle(fontSize: 20)),
                Text('Anesthésie', style: const TextStyle(fontSize: 20)),
                Card(
                  child: SizedBox(
                      height: 100,
                      child: Center(
                          child: Text(
                              patient.anesthesiaType
                                  .split('.')
                                  .last
                                  .toUpperCase(),
                              style: const TextStyle(fontSize: 20)))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 10),
                    Text(patient.birthDate?.toIso8601String() ?? '')
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.medical_services),
                    const SizedBox(width: 10),
                    Text(patient.observation.toString())
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.medical_services),
                    const SizedBox(width: 10),
                    Text(patient.comment ?? '')
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
