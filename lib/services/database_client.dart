import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rc_rtc_tolotanana/models/operation.dart';
import 'package:rc_rtc_tolotanana/models/patient.dart';
import 'package:rc_rtc_tolotanana/models/patient_operation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/edition.dart';

class DatabaseClient {
  //2 tables
  //1. liste de souhaits table. ex: liste informatique, liste de cadeaux (nom, id)
  //2. liste de souhaits items table. ex: ps5, clavier (nom, prix, magasin, image, id de la liste, id de l'item)
  //INTEGER, TEXT, REAL
  //INTEGER PRIMARY KEY pour id unique
  //TEXT NOT NULL

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
          id INTEGER PRIMARY KEY,
          year INTEGER NOT NULL,
          city TEXT NOT NULL
        )
      ''');
    await database.execute('''
        CREATE TABLE patient (
          id INTEGER PRIMARY KEY,
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
          id INTEGER PRIMARY KEY,
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

  // Synchroniser les éditions avec Firebase
  Future<void> syncEditionsWithFirebase(List<Edition> editions) async {
    for (Edition edition in editions) {
      await _editionsRef.child(edition.id.toString()).set(edition.toMap());
    }
  }

  // Synchroniser les patients avec Firebase
  Future<void> syncPatientsWithFirebase(List<Patient> patients) async {
    for (Patient patient in patients) {
      await _patientsRef.child(patient.id.toString()).set(patient.toMap());
    }
  }

  // Synchroniser les opérations avec Firebase
  Future<void> syncOperationsWithFirebase(List<Operation> operations) async {
    for (Operation operation in operations) {
      await _operationsRef
          .child(operation.id.toString())
          .set(operation.toMap());
    }
  }

  // Synchroniser les relations patient-opération avec Firebase
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
  Future<bool> addEdition(int year, String city) async {
    //recuperer le DB
    Database db = await database;
    // inserer dans la DB
    await db.insert("edition", {"year": year, "city": city});
    //notifier le changement terminé
    return true;
  }

  //Upsert patient
  Future<bool> upsert(Patient patient) async {
    //recuperer le DB
    Database db = await database;
    if (patient.id == null) {
      patient.id = await db.insert('patient', patient.toMap());
    } else {
      await db.update('patient', patient.toMap(),
          where: 'id = ?', whereArgs: [patient.id]);
    }
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
  Future<List<Patient>> patientFromEdition(int id) async {
    //recuperer le DB
    Database db = await database;

    List<Map<String, dynamic>> results =
        await db.query("patient", where: "edition = ?", whereArgs: [id]);

    // ou const query = 'SELECT * FROM item WHERE list = ?';
    // List<Map<String, dynamic>> results = await db.rawQuery(query, [id]);

    return results.map((map) => Patient.fromMap(map)).toList();
  }

  //get patient id from lastname
  Future<int> getPatientId(String lastname) async {
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
  Future<bool> addPatientOperation(int patientId, int operationId) async {
    //recuperer le DB
    Database db = await database;
    // inserer dans la DB
    await db.insert(
        "patient_operation", {"patient": patientId, "operation": operationId});
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
  Future<int> getNumberOfPatients() async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT COUNT(*) FROM patient';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query);
    //List<Map<String, dynamic>> results = await db.query("list");

    return results[0]['COUNT(*)'];
  }

  //get the minimum patient age
  Future<int> getMinAge() async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT MIN(age) FROM patient';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query);
    //List<Map<String, dynamic>> results = await db.query("list");

    return results[0]['MIN(age)'] ?? 0;
  }

  //get the maximum patient age
  Future<int> getMaxAge() async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT MAX(age) FROM patient';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query);
    //List<Map<String, dynamic>> results = await db.query("list");

    return results[0]['MAX(age)'] ?? 0;
  }

  //get the average patient age
  Future<int> getAverageAge() async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query = 'SELECT AVG(age) FROM patient';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query);
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
  Future<List<Map<String, dynamic>>> getPatientPerObservation() async {
    //recuperer le DB
    Database db = await database;
    //faire une query ou demande
    const query =
        'SELECT observation, COUNT(*) FROM patient GROUP BY observation';
    //recuperer les resultats
    List<Map<String, dynamic>> results = await db.rawQuery(query);
    //List<Map<String, dynamic>> results = await db.query("list");

    return results;
  }

  //get number of patient per sex
  Future<List<Map<String, dynamic>>> getPatientPerSex() async {
    Database db = await database;
    const query = "SELECT sex, COUNT(*) FROM patient GROUP BY sex";
    List<Map<String, dynamic>> results = await db.rawQuery(query);
    return results;
  }
}
