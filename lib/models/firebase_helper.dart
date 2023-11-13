import 'package:firebase_database/firebase_database.dart';

import 'patient.dart';

class FirebaseHelper {
  final DatabaseReference _patientDbRef =
      FirebaseDatabase.instance.ref().child('patients');

  Future<void> sendPatientToFirebase(Patient patient) async {
    await _patientDbRef.child(patient.id.toString()).set(patient.toMap());
  }

  Future<List<Patient>> getPatientsFromFirebase() async {
    final snapshot = await _patientDbRef.get();
    Map<dynamic, dynamic> patientsMap = snapshot.value as Map<dynamic, dynamic>;
    return patientsMap.values
        .map((patientMap) => Patient.fromMap(patientMap))
        .toList();
  }
}
