import 'package:flutter/material.dart';
import 'package:rc_rtc_tolotanana/models/patient.dart';

class PatientTile extends StatelessWidget {
  final Patient patient;
  const PatientTile({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          patient.sex == 0 ? const Icon(Icons.man) : const Icon(Icons.woman),
      trailing: const Icon(Icons.arrow_forward_ios),
      title:
          Text('${patient.lastname} ${patient.firstname} - ${patient.age} ans'),
      subtitle: Text(patient.observation.toString()),
    );
  }
}
