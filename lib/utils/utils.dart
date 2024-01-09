import 'package:flutter/material.dart';

Map<String, dynamic> getStatusDetails(int? id) {
  switch (id) {
    case 1:
      return {
        'day': 'LUNDI',
        'color': Colors.red[900],
      };
    case 2:
      return {
        'day': 'MARDI',
        'color': Colors.orange[700],
      };
    case 3:
      return {
        'day': 'MERCREDI',
        'color': Colors.yellow[700],
      };
    case 4:
      return {
        'day': 'JEUDI',
        'color': Colors.green[700],
      };
    case 5:
      return {
        'day': 'VENDREDI',
        'color': Colors.blue[700],
      };
    case null:
      return {
        'day': 'Non programmé',
        'color': Colors.grey[700],
      };
    default:
      return {
        'day': 'Non programmé',
        'color': Colors.grey[700],
      };
  }
}
