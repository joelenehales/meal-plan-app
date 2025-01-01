import 'package:flutter/material.dart';

enum DialogType { error, confirmation }

extension DialogTypeExtention on DialogType {
  String get label {
    switch (this) {
      case DialogType.error:
        return 'Error';
      case DialogType.confirmation:
        return 'Success';
      default:
        return 'Other';
    }
  }
}

Future<void> customDialog(
    String message, DialogType type, BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(type.label),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
