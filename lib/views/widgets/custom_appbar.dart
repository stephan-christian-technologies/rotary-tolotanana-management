import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rc_rtc_tolotanana/services/database.dart';
import 'package:sqflite/sqflite.dart';

class CustomAppBar extends AppBar {
  String titleString;
  String buttonTitle;
  VoidCallback callback;
  VoidCallback? callback2;

  CustomAppBar(
      {super.key,
      required this.titleString,
      required this.buttonTitle,
      required this.callback,
      this.callback2})
      : super(title: Text(titleString), actions: [
          TextButton(
              onPressed: callback,
              child: Text(
                buttonTitle,
                style: const TextStyle(color: Colors.black),
              )),
          IconButton(
              onPressed: () async {
                Get.snackbar('Synchronisation', 'En cours...');
                if (callback2 != null) {
                  DatabaseClient()
                      .syncFirebaseDataToLocalStorage()
                      .then((value) => callback2());
                } else {
                  await DatabaseClient().syncFirebaseDataToLocalStorage();
                }
              },
              icon: const Icon(Icons.refresh))
        ]);

  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
