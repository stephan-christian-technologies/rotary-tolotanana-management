import 'package:flutter/material.dart';

import '../../models/edition.dart';

class EditionTile extends StatelessWidget {
  final Edition edition;
  final Function(Edition) onPressed;
  final Function(Edition) onDeleted;
  const EditionTile(
      {super.key,
      required this.edition,
      required this.onPressed,
      required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return
        // ListTile(
        //   title: Text('${edition.city} ${edition.year}'),
        //   onTap: (() => onPressed(edition)),
        //   trailing: IconButton(
        //       onPressed: (() => onDeleted(edition)),
        //       icon: const Icon(Icons.delete)),
        // );
        Dismissible(
      key: Key(edition.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDeleted(edition),
      background: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.black, Colors.red],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Icon(Icons.delete, color: Colors.white, size: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      child: InkWell(
        onTap: () => onPressed(edition),
        child: Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 16.0,
                      ),
                      Text('${edition.year}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 24)),
                      Text(edition.city,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 24)),
                    ],
                  ),
                  IconButton(
                      onPressed: (() => onDeleted(edition)),
                      icon: const Text('x', style: TextStyle(fontSize: 24))),
                ],
              ),
            )),
      ),
    );
  }
}
