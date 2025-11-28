import 'package:flutter/material.dart';

Future<String?> askMasterPasswordDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      final controller = TextEditingController();

      return AlertDialog(
        title: const Text("Enter Master Password"),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Master password"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text("Confirm"),
          ),
        ],
      );
    },
  );
}
