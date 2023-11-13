class PatientOperation {
  final String id;
  final String? patientId;
  final String? operationId;

  PatientOperation({
    required this.id,
    this.patientId,
    this.operationId,
  });

  factory PatientOperation.fromJson(Map<String, dynamic> json) {
    return PatientOperation(
      id: json['id'].toString(),
      patientId: json['patient'].toString(),
      operationId: json['operation'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient': patientId,
        'operation': operationId,
      };

  //toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient': patientId,
      'operation': operationId,
    };
  }
}
