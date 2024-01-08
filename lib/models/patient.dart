import 'package:uuid/uuid.dart';

class Patient {
  String id;
  int folderId;
  String lastname;
  String? firstname;
  int age;
  int sex;
  String anesthesiaType;
  String telephone;
  int observation;
  String? comment;
  String? address;
  DateTime? birthDate;
  String edition;
  int? status;

  Patient(
      {required this.id,
      required this.folderId,
      required this.lastname,
      this.firstname,
      required this.age,
      required this.sex,
      required this.anesthesiaType,
      required this.telephone,
      required this.observation,
      this.comment,
      this.address,
      this.birthDate,
      this.status,
      required this.edition});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'folderId': folderId,
      'lastname': lastname,
      'firstname': firstname,
      'age': age,
      'sex': sex,
      'anesthesiaType': anesthesiaType,
      'telephone': telephone,
      'observation': observation,
      'comment': comment,
      'address': address,
      'birthDate': birthDate?.toIso8601String(),
      'edition': edition,
      'status': status,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Patient.fromMap(Map<String, dynamic> data) {
    return Patient(
      id: data['id'] ?? const Uuid().v4(),
      folderId: data['folderId'],
      lastname: data['lastName'],
      firstname: data['firstName'],
      age: data['age'],
      sex: data['sex'],
      anesthesiaType: data['anesthesiaType'],
      telephone: data['telephone'],
      observation: data['observation'],
      comment: data['comment'],
      address: data['address'],
      birthDate: DateTime.parse(data['birthDate']),
      edition: data['edition'],
      status: data['status'],
    );
  }
}

enum Sex { male, female }

enum OperationType {
  flg,
  fld,
  flpg,
  hisd,
  hisg,
  lipome,
  hydrocele,
  kyste,
  brulure,
  other
}

enum AnesthesiaType { local, general, locogeneral, other }

enum Observation { able, unable }
