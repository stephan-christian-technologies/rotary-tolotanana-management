// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

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
  int status;
  String? weight;
  String? bloodPressure;

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
      required this.status,
      this.weight,
      this.bloodPressure,
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
      'weight': weight ?? '',
      'bloodPressure': bloodPressure ?? '',
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Patient.fromMap(Map<String, dynamic> data) {
    return Patient(
      id: data['id'].toString() ?? const Uuid().v4(),
      folderId: int.parse(data['folderId'].toString()),
      lastname: data['lastname'].toString(),
      firstname: data['firstname'].toString(),
      age: int.parse(data['age'].toString()),
      sex: int.parse(data['sex'].toString()),
      anesthesiaType: data['anesthesiaType'].toString(),
      telephone: data['telephone'].toString(),
      observation: int.parse(data['observation'].toString()),
      comment: data['comment'].toString(),
      address: data['address'].toString(),
      birthDate: data['birthDate'].toString() == ''
          ? null
          : DateTime.parse(data['birthDate'].toString()),
      edition: data['edition'].toString(),
      status: int.parse(data['status'].toString()),
      weight: data['weight'].toString(),
      bloodPressure: data['bloodPressure'].toString(),
    );
  }

  Patient copyWith({
    String? id,
    int? folderId,
    String? lastname,
    String? firstname,
    int? age,
    int? sex,
    String? anesthesiaType,
    String? telephone,
    int? observation,
    String? comment,
    String? address,
    DateTime? birthDate,
    String? edition,
    int? status,
    String? weight,
    String? bloodPressure,
  }) {
    return Patient(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      lastname: lastname ?? this.lastname,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      anesthesiaType: anesthesiaType ?? this.anesthesiaType,
      telephone: telephone ?? this.telephone,
      observation: observation ?? this.observation,
      edition: edition ?? this.edition,
      status: status ?? this.status,
      weight: weight ?? this.weight,
      bloodPressure: bloodPressure ?? this.bloodPressure,
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
