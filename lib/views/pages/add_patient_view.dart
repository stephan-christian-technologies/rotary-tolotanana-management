// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:rc_rtc_tolotanana/models/edition.dart';
import 'package:rc_rtc_tolotanana/models/operation.dart';
import 'package:rc_rtc_tolotanana/models/patient.dart';
import 'package:rc_rtc_tolotanana/views/pages/edition_details_view.dart';
import 'package:rc_rtc_tolotanana/views/widgets/add_textfield.dart';
import 'package:rc_rtc_tolotanana/views/widgets/custom_appbar.dart';
import 'package:uuid/uuid.dart';

import '../../services/database.dart';

class AddPatientView extends StatefulWidget {
  final Edition edition;

  const AddPatientView({Key? key, required this.edition}) : super(key: key);

  @override
  State<AddPatientView> createState() => _AddPatientViewState();
}

class _AddPatientViewState extends State<AddPatientView> {
  late TextEditingController folderIdController;
  late TextEditingController nameController;
  late TextEditingController firstNameController;
  late TextEditingController ageController;
  late int? sexeController;
  late TextEditingController adresseController;
  late TextEditingController telephoneController;
  late List<String>? typeOperationController;
  late AnesthesiaType? typeAnesthesieController;
  late int? observationController;
  late TextEditingController commentaireController;
  late TextEditingController weightController;
  late TextEditingController bloodPressureController;
  late TextEditingController dateNaissanceController;

  @override
  void initState() {
    folderIdController = TextEditingController();
    nameController = TextEditingController();
    firstNameController = TextEditingController();
    ageController = TextEditingController();
    sexeController = null;
    adresseController = TextEditingController();
    telephoneController = TextEditingController();
    typeOperationController = [];
    typeAnesthesieController = null;
    observationController = null;
    commentaireController = TextEditingController();
    dateNaissanceController = TextEditingController();
    weightController = TextEditingController();
    bloodPressureController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    folderIdController.dispose();
    nameController.dispose();
    firstNameController.dispose();
    ageController.dispose();
    sexeController = null;
    adresseController.dispose();
    telephoneController.dispose();
    typeOperationController = null;
    typeAnesthesieController = null;
    observationController = null;
    commentaireController.dispose();
    dateNaissanceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: 'Ajout de patient',
        buttonTitle: 'Valider',
        callback: addPressed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AddTextfield(
                  hint: "Numéro de dossier",
                  controller: folderIdController,
                  textInputType: TextInputType.number,
                ),
                AddTextfield(
                  hint: "Nom de famille",
                  controller: nameController,
                ),
                AddTextfield(
                  hint: "Prénom(s)",
                  controller: firstNameController,
                ),
                AddTextfield(
                  hint: "Age",
                  controller: ageController,
                  textInputType: TextInputType.number,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: dateNaissanceController,
                    decoration: const InputDecoration(
                      hintText: 'Date de naissance',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      labelText: 'Date de naissance',
                    ),
                    onTap: () async {
                      DateTime? date = DateTime(1900);
                      FocusScope.of(context).requestFocus(FocusNode());

                      date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );

                      dateNaissanceController.text =
                          date?.toIso8601String() ?? '';
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sexe'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Radio(
                              value: 0,
                              groupValue: sexeController,
                              onChanged: (value) {
                                setState(() {
                                  sexeController = value;
                                });
                              },
                            ),
                            const Text('Masculin'),
                            const Spacer(),
                            Radio(
                              value: 1,
                              groupValue: sexeController,
                              onChanged: (value) {
                                setState(() {
                                  sexeController = value;
                                });
                              },
                            ),
                            const Text('Féminin'),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AddTextfield(
                  hint: "Adresse",
                  controller: adresseController,
                ),
                AddTextfield(
                  hint: "Téléphone",
                  controller: telephoneController,
                  textInputType: TextInputType.phone,
                ),
                FutureBuilder(
                  future: DatabaseClient().allOperations(),
                  builder: (context, AsyncSnapshot<List<Operation>> snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Type d\'opération',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Column(
                                children: snapshot.data!.map((operation) {
                                  return CheckboxListTile.adaptive(
                                    value: typeOperationController!
                                            .contains(operation.name)
                                        ? true
                                        : false,
                                    title: Text(operation.name.split('.')[1]),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          typeOperationController =
                                              typeOperationController!
                                                  .toSet()
                                                  .union({
                                            operation.name
                                          }).toList();
                                        } else {
                                          typeOperationController =
                                              typeOperationController!
                                                  .toSet()
                                                  .difference({
                                            operation.name
                                          }).toList();
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text('Type d\'anesthésie'),
                      DropdownButton<AnesthesiaType>(
                        hint: const Text('Type d\'anesthésie'),
                        value: typeAnesthesieController,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.blueAccent),
                        underline: Container(
                          height: 2,
                          color: Colors.blue,
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            typeAnesthesieController = newValue!;
                          });
                        },
                        items: AnesthesiaType.values
                            .map<DropdownMenuItem<AnesthesiaType>>((value) {
                          return DropdownMenuItem<AnesthesiaType>(
                            value: value,
                            child: Text(
                              value.toString().split('.')[1].toUpperCase(),
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Observation'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Radio(
                              value: 1,
                              groupValue: observationController,
                              onChanged: (value) {
                                setState(() {
                                  observationController = value;
                                });
                              },
                            ),
                            const Text('Apte'),
                            const Spacer(),
                            Radio(
                              value: 0,
                              groupValue: observationController,
                              onChanged: (value) {
                                setState(() {
                                  observationController = value;
                                });
                              },
                            ),
                            const Text('inapte'),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    hintText: 'Poids',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    labelText: 'Poids',
                  ),
                  keyboardType: TextInputType.number),
                TextField(
                  controller: bloodPressureController,
                  decoration: const InputDecoration(
                    hintText: 'Tension artérielle',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    labelText: 'Tension artérielle',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: commentaireController,
                  decoration: const InputDecoration(
                    hintText: 'Commentaire',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    labelText: 'Commentaire',
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  addPressed() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (nameController.text.isEmpty) return;

    Map<String, dynamic> map = {'edition': widget.edition.id};
    map['folderId'] = int.parse(folderIdController.text);
    map['lastname'] = nameController.text;
    map['firstname'] = firstNameController.text;
    map['age'] = int.parse(ageController.text);
    map['sex'] = sexeController;
    map['address'] = adresseController.text;
    map['telephone'] = telephoneController.text;
    map['operationType'] = typeOperationController;
    map['anesthesiaType'] = typeAnesthesieController.toString();
    map['observation'] = observationController;
    map['comment'] = commentaireController.text;
    map['birthDate'] = dateNaissanceController.text;
    map['weight'] = weightController.text;
    map['bloodPressure'] = bloodPressureController.text;
    map['status'] = 0;

    const uuid = Uuid();
    map['id'] = uuid.v4();
    Patient patient = Patient.fromMap(map);
    try {
      await DatabaseClient().insert(patient);

      final patientId = patient.id;

      for (var operation in typeOperationController!) {
        final operationId = await DatabaseClient().getOperationId(operation);
        await DatabaseClient()
            .addPatientOperation(null, patientId, operationId);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('Erreur'),
                content: Text(
                    'Une erreur est survenue lors de l\'ajout du patient: $e'),
              ));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${patient.lastname} ajouté avec succès')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditionDetailsView(
          edition: widget.edition,
        ),
      ),
    );
  }
}
