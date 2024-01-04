import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rc_rtc_tolotanana/models/operation.dart';
import 'package:rc_rtc_tolotanana/models/patient.dart';
import 'package:rc_rtc_tolotanana/models/patient_operation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/edition.dart';

class DatabaseClient {
  // acceder a la DB
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return database;
    } else {
      return await createDatabase();
    }
  }

  Future<Database> createDatabase() async {
    //recuperer les dossiers dans l'application
    Directory directory = await getApplicationDocumentsDirectory();
    //Creer un chemin pour la DB
    final path = join(directory.path, "tolotanana.db");
    return await openDatabase(path, version: 1, onCreate: onCreate);
  }

  onCreate(Database database, int version) async {
    await database.execute('''
        CREATE TABLE edition (
          id TEXT PRIMARY KEY,
          year INTEGER NOT NULL,
          city TEXT NOT NULL
        )
      ''');
    await database.execute('''
        CREATE TABLE patient (
          id TEXT PRIMARY KEY,
          lastName TEXT NOT NULL,
          firstName TEXT NOT NULL,
          age INTEGER NOT NULL,
          sex INTEGER NOT NULL,
          anesthesiaType TEXT NOT NULL,
          telephone TEXT NOT NULL,
          observation INTEGER NOT NULL,
          comment TEXT,
          address TEXT,
          birthDate TEXT NOT NULL,
          edition INTEGER,
          FOREIGN KEY(edition) REFERENCES edition(id)
        )
      ''');
    await database.execute('''
        CREATE TABLE operation (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL
        )
      ''');
    await database.execute('''
        CREATE TABLE patient_operation (
          id TEXT PRIMARY KEY,
          patient INTEGER,
          operation INTEGER,
          FOREIGN KEY(patient) REFERENCES patient(id),
          FOREIGN KEY(operation) REFERENCES operation(id)
        )
      ''');
    //insert each operationType in the table operation
    for (var operation in OperationType.values) {
      await database.rawInsert(
          'INSERT INTO operation (name) VALUES (?)', [operation.toString()]);
    }
  }

  final DatabaseReference _editionsRef =
      FirebaseDatabase.instance.ref('editions');
  final DatabaseReference _patientsRef =
      FirebaseDatabase.instance.ref('patients');
  final DatabaseReference _operationsRef =
      FirebaseDatabase.instance.ref('operations');
  final DatabaseReference _patientOperationsRef =
      FirebaseDatabase.instance.ref('patient_operations');

  // Synchroniser les éditions vers Firebase
  Future<void> syncEditionsWithFirebase(List<Edition> editions) async {
    for (Edition edition in editions) {
      try {
        // Check if edition already exists in Firebase
        DataSnapshot dataSnapshot =
            await _editionsRef.child(edition.id.toString()).get();

        if (dataSnapshot.value == null) {
          // Edition doesn't exist, so set it in Firebase
          await _editionsRef.child(edition.id.toString()).set(edition.toMap());
        } else {
          // Edition already exists, skip it
          print(
              'Edition with ID ${edition.id} already exists in Firebase. Skipped.');
        }
      } catch (error) {
        // Handle any errors that might occur during Firebase operations
        print('Error syncing edition with ID ${edition.id}: $error');
      }
    }
  }

  // Synchroniser les patients vers Firebase
  Future<void> syncPatientsWithFirebase(List<Patient> patients) async {
    for (Patient patient in patients) {
      await _patientsRef.child(patient.id.toString()).set(patient.toMap());
    }
  }

  // Synchroniser les opérations vers Firebase
  Future<void> syncOperationsWithFirebase(List<Operation> operations) async {
    for (Operation operation in operations) {
      await _operationsRef
          .child(operation.id.toString())
          .set(operation.toMap());
    }
  }

  // Synchroniser les relations patient-opération vers Firebase
  Future<void> syncPatientOperationsWithFirebase(
      List<PatientOperation> patientOperations) async {
    for (PatientOperation patientOperation in patientOperations) {
      await _patientOperationsRef
          .child(patientOperation.id.toString())
          .set(patientOperation.toMap());
    }
  }

  Future<void> syncAllDataWithFirebase() async {
    List<Edition> editions = await allEditions();
    List<Patient> patients = await allPatients();
    List<Operation> operations = await allOperations();
    List<PatientOperation> patientOperations = await getAllPatientOperations();

    await syncEditionsWithFirebase(editions);
    await syncPatientsWithFirebase(patients);
    await syncOperationsWithFirebase(operations);
    await syncPatientOperationsWithFirebase(patientOperations);
  }

  Future<void> syncFirebaseDataToLocalStorage() async {
    List<Edition> editions = await _getEditionsFromFirebase();
    List<Patient> patients = await _getPatientsFromFirebase();
    List<PatientOperation> patientOperations =
        await _getPatientOperationsFromFirebase();

    await _deleteAllEditions();
    await _deleteAllPatients();
    await _deleteAllPatientOperations();

    await syncEditionsToLocalStorage(editions);
    await syncPatientsToLocalStorage(patients);
    await syncPatientOperationsToLocalStorage(patientOperations);
  }

  Future<List<Edition>> _getEditionsFromFirebase() async {
    List<Edition> editions = [];
    DataSnapshot dataSnapshot = await _editionsRef.get();
    Map<dynamic, dynamic> editionsMap =
        dataSnapshot.value as Map<dynamic, dynamic>;
    editionsMap.forEach((key, value) async {
      final id = value['id'];
      final year = value['year'];
      final city = value['city'];

      final edition = await getEdition(id);
      if (edition == null) {
        editions.add(Edition(id, year, city));
      } else {
        print('Edition with ID $id already exists in local storage. Skipped.');
      }
    });
    return editions;
  }

  Future<List<Patient>> _getPatientsFromFirebase() async {
    List<Patient> patients = [];
    DataSnapshot dataSnapshot = await _patientsRef.get();
    Map<dynamic, dynamic> patientsMap =
        dataSnapshot.value as Map<dynamic, dynamic>;
    patientsMap.forEach((key, value) {
      final id = value['id'];
      final firstname = value['firstname'];
      final lastname = value['lastname'];
      final address = value['address'];
      final age = value['age'];
      final anesthesiaType = value['anesthesiaType'];
      final observation = value['observation'];
      final sex = value['sex'];
      final telephone = value['telephone'];
      final edition = value['edition'];
      final birthDate = value['birthDate'];
      final comment = value['comment'] ?? '';

      patients.add(Patient(
          id: id,
          lastname: lastname,
          firstname: firstname,
          age: age,
          sex: sex,
          anesthesiaType: anesthesiaType,
          birthDate: DateTime.parse(birthDate),
          address: address,
          telephone: telephone,
          observation: observation,
          edition: edition,
          comment: comment));
    });
    return patients;
  }

  Future<List<PatientOperation>> _getPatientOperationsFromFirebase() async {
    List<PatientOperation> patientOperations = [];
    DataSnapshot dataSnapshot = await _patientOperationsRef.get();
    Map<dynamic, dynamic> patientOperationsMap =
        dataSnapshot.value as Map<dynamic, dynamic>;
    patientOperationsMap.forEach((key, value) {
      final id = value['id'];
      final patientId = value['patient'];
      final operationId = value['operation'];

      patientOperations.add(PatientOperation(
          id: id, patientId: patientId, operationId: operationId));
    });
    return patientOperations;
  }

  Future<void> _deleteAllEditions() async {
    Database db = await database;
    await db.delete("edition");
  }

  Future<void> _deleteAllPatients() async {
    Database db = await database;
    await db.delete("patient");
  }

  Future<void> _deleteAllPatientOperations() async {
    Database db = await database;
    await db.delete("patient_operation");
  }

  Future<void> syncEditionsToLocalStorage(List<Edition> editions) async {
    for (Edition edition in editions) {
      await addEdition(edition.id, edition.year, edition.city);
    }
  }

  Future<void> syncPatientsToLocalStorage(List<Patient> patients) async {
    for (Patient patient in patients) {
      await insert(patient);
    }
  }

  Future<void> syncPatientOperationsToLocalStorage(
      List<PatientOperation> patientOperations) async {
    for (PatientOperation patientOperation in patientOperations) {
      await addPatientOperation(
          patientOperation.id,
          patientOperation.patientId!,
          int.parse(patientOperation.operationId!));
    }
  }

  //list of all patients
  Future<List<Patient>> allPatients() async {
    List<Patient> patients = [];
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT * FROM patient';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query);
    //List<Map<String, dynamic>> results = await db.query("list");

    for (var map in results) {
      patients.add(Patient.fromMap(map));
    }
    //ou return results.map((map) => WishList.fromMap(map)).toList();
    return patients;
  }

  //list of all PatientOperations
  Future<List<PatientOperation>> getAllPatientOperations() async {
    List<PatientOperation> patientOperations = [];
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT * FROM patient_operation';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query);

    for (var map in results) {
      patientOperations.add(PatientOperation.fromJson(map));
    }

    return patientOperations;
  }

  //list of all operations
  Future<List<Operation>> allOperations() async {
    List<Operation> operations = [];
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT * FROM operation';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query);
    //List<Map<String, dynamic>> results = await db.query("list");

    for (var map in results) {
      operations.add(Operation.fromMap(map));
    }
    //ou return results.map((map) => WishList.fromMap(map)).toList();
    return operations;
  }

  //Obtenir données
  Future<List<Edition>> allEditions() async {
    List<Edition> lists = [];
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT * FROM edition ORDER BY year DESC';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query);
    //List<Map<String, dynamic>> results = await db.query("list");

    for (var map in results) {
      lists.add(Edition.fromMap(map));
    }
    //ou return results.map((map) => WishList.fromMap(map)).toList();
    return lists;
  }

  //Ajouter données
  Future<bool> addEdition(String? id, int year, String city) async {
    Database db = await database;
    final newId = generateUuid();
    await db.insert("edition", {"id": id ?? newId, "year": year, "city": city},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return true;
  }

  //Upsert patient
  Future<bool> upsert(Patient patient) async {
    Database db = await database;
    if (patient.id == null) {
      final id = generateUuid();
      patient.id = id;
      await db.insert('patient', patient.toMap());
    } else {
      await db.update('patient', patient.toMap(),
          where: 'id = ?', whereArgs: [patient.id]);
    }
    return true;
  }

  //Insert patient
  Future<bool> insert(Patient patient) async {
    Database db = await database;
    await db.insert('patient', patient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return true;
  }

  //supprimer wishlist
  Future<bool> deleteEdition(Edition edition) async {
    //recuperer le DB
    Database db = await database;
    //supprimer dans la DB
    await db.delete("edition", where: "id = ?", whereArgs: [edition.id]);
    //supprimer aussi les items de la liste
    await db.delete("patient", where: "edition = ?", whereArgs: [edition.id]);
    //notifier le changement terminé
    return true;
  }

  //Obtenir les items
  Future<List<Patient>> patientFromEdition(String id) async {
    //recuperer le DB
    Database db = await database;

    List<Map<String, dynamic>> results =
        await db.query("patient", where: "edition = ?", whereArgs: [id]);

    // ou const query = 'SELECT * FROM item WHERE list = ?';
    // List<Map<String, dynamic>> results = await db.rawQuery(query, [id]);

    return results.map((map) => Patient.fromMap(map)).toList();
  }

  //get patient from id
  Future<Patient> getPatient(String id) async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT * FROM patient WHERE id = ?';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query, [id]);
    //List<Map<String, dynamic>> results = await db.query("list");

    return Patient.fromMap(results[0]);
  }

  //get edition from id
  Future<Edition?> getEdition(String id) async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT * FROM edition WHERE id = ?';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query, [id]);
    //List<Map<String, dynamic>> results = await db.query("list");

    if (results.isEmpty) {
      return null;
    } else {
      return Edition.fromMap(results[0]);
    }
  }

  //get patient id from lastname
  Future<String> getPatientId(String lastname) async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT id FROM patient WHERE lastName = ?';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query, [lastname]);
    //List<Map<String, dynamic>> results = await db.query("list");

    return results[0]['id'];
  }

  //add patient_operation
  Future<bool> addPatientOperation(
      String? id, String patientId, int operationId) async {
    Database db = await database;
    await db.insert(
        "patient_operation",
        {
          "id": id ?? generateUuid(),
          "patient": patientId,
          "operation": operationId
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
    //notifier le changement terminé
    return true;
  }

  //get operation id from name
  Future<int> getOperationId(String name) async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT id FROM operation WHERE name = ?';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query, [name]);
    //List<Map<String, dynamic>> results = await db.query("list");

    return results[0]['id'];
  }

  //get number of patients
  Future<int> getNumberOfPatients(String editionId) async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT COUNT(*) FROM patient WHERE edition = ?';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query, [editionId]);
    //List<Map<String, dynamic>> results = await db.query("list");

    return results[0]['COUNT(*)'];
  }

  //get patients by edition id
  Future<List<Patient>> getPatientsByEditionId(String editionId) async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT * FROM patient WHERE edition = ?';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query, [editionId]);
    //List<Map<String, dynamic>> results = await db.query("list");

    return results.map((map) => Patient.fromMap(map)).toList();
  }

  //get the minimum patient age
  Future<int> getMinAge(String editionId) async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT MIN(age) FROM patient WHERE edition = ?';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query, [editionId]);
    //List<Map<String, dynamic>> results = await db.query("list");

    return results[0]['MIN(age)'] ?? 0;
  }

  //get the maximum patient age
  Future<int> getMaxAge(String editionId) async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT MAX(age) FROM patient WHERE edition = ?';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query, [editionId]);
    //List<Map<String, dynamic>> results = await db.query("list");

    return results[0]['MAX(age)'] ?? 0;
  }

  //get the average patient age
  Future<int> getAverageAge(String editionId) async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT AVG(age) FROM patient WHERE edition = ?';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query, [editionId]);
    //List<Map<String, dynamic>> results = await db.query("list");

    return results[0]['AVG(age)']?.toInt() ?? 0;
  }

  //get number of patient per operationType
  Future<List<Map<String, dynamic>>> getPatientPerOperationType() async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query =
        'SELECT operation.name, COUNT(*) FROM patient_operation INNER JOIN operation ON patient_operation.operation = operation.id GROUP BY operation.name';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query);
    //List<Map<String, dynamic>> results = await db.query("list");

    return results;
  }

  //get number of patient per observation
  Future<List<Map<String, dynamic>>> getPatientPerObservation(
      String editionId) async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query =
        'SELECT observation, COUNT(*) FROM patient WHERE edition = ? GROUP BY observation';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query, [editionId]);
    //List<Map<String, dynamic>> results = await db.query("list");

    return results;
  }

  //get number of patient per sex
  Future<List<Map<String, dynamic>>> getPatientPerSex(String editionId) async {
    Database db = await database;
    const query =
        "SELECT sex, COUNT(*) FROM patient WHERE edition = ? GROUP BY sex";
    List<Map<String, dynamic>> results = await db.rawQuery(query, [editionId]);
    return results;
  }

  String generateUuid() {
    var uuid = const Uuid();
    return uuid.v4();
  }
}
