import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  String titleString;
  String buttonTitle;
  VoidCallback callback;

  CustomAppBar(
      {super.key,
      required this.titleString,
      required this.buttonTitle,
      required this.callback})
      : super(title: Text(titleString), actions: [
          TextButton(
              onPressed: callback,
              child: Text(
                buttonTitle,
                style: const TextStyle(color: Colors.black),
              ))
        ]);

  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
