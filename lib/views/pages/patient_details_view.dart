import 'package:flutter/material.dart';
import 'package:rc_rtc_tolotanana/models/patient.dart';
import 'package:rc_rtc_tolotanana/utils/utils.dart';

class PatientDetailsPage extends StatefulWidget {
  const PatientDetailsPage({Key? key, required this.patient}) : super(key: key);
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: patient.sex == 0 ? Colors.blue : Colors.pink,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${patient.lastname} ${patient.firstname ?? ''}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'N° ${patient.folderId} - ${patient.age} ans',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  patient.observation.toString() == '1' ? 'Apte' : 'Inapte',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 100),
              Row(
                children: [
                  const Icon(Icons.calendar_month),
                  const SizedBox(width: 10),
                  const Text("Jour d'intervention: ", style: TextStyle(fontSize: 18)),
                  const Spacer(),
                  Text(
                    (patient.status.toString() != 'null' &&
                            patient.observation.toString() == '1')
                        ? getStatusDetails(patient.status)['day']
                        : (patient.status.toString() == 'null' &&
                                patient.observation.toString() == '1')
                            ? 'Pas encore programmé'
                            : 'Pas programmé pour cette mission',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.info),
                  SizedBox(width: 10),  
                  Text(
                    'Diagnostic: ',
                    style: TextStyle(fontSize: 18),
                  ),
                  Spacer(),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.local_hospital),
                  const SizedBox(width: 10),
                  const Text(
                    'Anesthésie: ',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  Text(
                    patient.anesthesiaType
                        .split('.')
                        .last
                        .toUpperCase(),
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 10),
                  const Text('Date de naissance: ', style: TextStyle(fontSize: 18)),
                  const Spacer(),
                  Text(DateTime.parse(patient.birthDate.toString())
                      .toLocal()
                      .toString()
                      .split(' ')[0]),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.message),
                  const SizedBox(width: 10),
                  const Text('Commentaire: ', style: TextStyle(fontSize: 18)),
                  const Spacer(),
                  Text(patient.comment ?? ''),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
