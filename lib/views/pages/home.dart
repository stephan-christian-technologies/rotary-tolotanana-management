import 'package:flutter/material.dart';
import 'package:rc_rtc_tolotanana/views/pages/edition_details_view.dart';
import 'package:rc_rtc_tolotanana/views/tiles/edition_tile.dart';
import 'package:rc_rtc_tolotanana/views/widgets/add_dialog.dart';

import '../../models/edition.dart';
import '../../services/database.dart';
import '../widgets/custom_appbar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Edition> editions = [];

  @override
  void initState() {
    getEditions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "Liste des éditions",
        buttonTitle: "Ajouter",
        callback: addEdition,
      ),
      body: ListView.builder(
          itemBuilder: ((context, index) {
            final edition = editions[index];
            return EditionTile(
                edition: edition,
                onPressed: onEditionPressed,
                onDeleted: onDeleteEdition);
          }),
          itemCount: editions.length),
    );
  }

  getEditions() async {
    final fromDb = await DatabaseClient().allEditions();
    setState(() {
      editions = fromDb;
    });
  }

  addEdition() async {
    await showDialog(
        context: context,
        builder: (context) {
          final yearController = TextEditingController();
          final cityController = TextEditingController();
          return AddDialog(
              yearCtrl: yearController,
              cityCtrl: cityController,
              onCancel: handleCloseDialog,
              onValidate: (() {
                Navigator.pop(context);
                if (yearController.text.isEmpty) return;
                if (cityController.text.isEmpty) return;
                //ajouter a la DB et rafraichir la liste
                DatabaseClient()
                    .addEdition(null, int.parse(yearController.text),
                        cityController.text)
                    .then((success) => getEditions());
              }));
        });
  }

  handleCloseDialog() {
    Navigator.pop(context);
    FocusScope.of(context).unfocus(); //fermer le clavier si ouvert
  }

  onEditionPressed(Edition edition) {
    final next = EditionDetailsView(edition: edition);
    Navigator.push(context, MaterialPageRoute(builder: (context) => next));
  }

  onDeleteEdition(Edition edition) {
    DatabaseClient().deleteEdition(edition).then((success) {
      getEditions();
    });
  }
}
