import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_passman_client/controllers/password_controller.dart';
import 'package:flutter_passman_client/models/passentry.dart';
import 'package:provider/provider.dart';
import 'package:flutter_passman_client/ui/_core/app_colors.dart';
import 'package:flutter_passman_client/ui/_core/widgets/appbar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EditScreen extends StatefulWidget {
  final PassEntry entry;
  const EditScreen({super.key, required this.entry});
  static const route = "/edit";

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late final TextEditingController serviceCtrl;
  late final TextEditingController passwordCtrl;
  late final TextEditingController descriptionCtrl;
  late final TextEditingController masterCtrl;
  bool passwordVisible = false;
  bool masterVisible = false;

  @override
  void initState() {
    super.initState();
    serviceCtrl = TextEditingController(text: widget.entry.service);
    passwordCtrl = TextEditingController(text: widget.entry.secret);
    descriptionCtrl = TextEditingController(
      text: widget.entry.description ?? "",
    );
    masterCtrl = TextEditingController(text: widget.entry.master ?? "");
  }

  @override
  void dispose() {
    serviceCtrl.dispose();
    passwordCtrl.dispose();
    descriptionCtrl.dispose();
    masterCtrl.dispose();
    super.dispose();
  }

  Future<void> importFileAsPassword() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) return;

    final file = File(path);
    final content = await file.readAsString();

    if (!mounted) return;
    setState(() {
      passwordCtrl.text = content.trim();
    });
  }

  void showSnackbar({required String message, required bool success}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.remove_circle,
              color: AppColors.backgroundColor,
            ),
            const SizedBox(width: 16),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: AppColors.mainColor,
      ),
    );
  }

  String generatePassword([int length = 16]) {
    const lower = 'abcdefghijkmnopqrstuvwxyz';
    const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const digits = '23456789';
    const symbols = '!@#\$^&*()-_+';
    final all = '$lower$upper$digits$symbols';
    final rand = Random.secure();
    return List.generate(length, (_) => all[rand.nextInt(all.length)]).join();
  }

  void updatePassword() async {
    final svc = serviceCtrl.text.trim();
    final pwd = passwordCtrl.text.trim();
    final desc = descriptionCtrl.text.trim();
    final master = masterCtrl.text.trim();

    if (svc.isEmpty || master.isEmpty) {
      showSnackbar(
        message: "Service and master password are required.",
        success: false,
      );
      return;
    }

    final controller = context.read<PasswordController>();
    final navigator = Navigator.of(context);

    try {
      await controller.updatePassword(
        id: widget.entry.id,
        service: svc,
        masterPassword: master,
        plainPassword: pwd,
        description: desc,
      );
    } catch (e) {
      if (!mounted) return;
      showSnackbar(message: "Failed to update: $e", success: false);
      return;
    }

    if (!mounted) return;
    showSnackbar(message: "Password updated!", success: true);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: getAppBar(title: 'Edit Password'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: serviceCtrl,
              decoration: const InputDecoration(labelText: "Service"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordCtrl,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => passwordVisible = !passwordVisible);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.file_open),
                      tooltip: "Import Password from File",
                      onPressed: importFileAsPassword,
                    ),
                    IconButton(
                      icon: const Icon(Icons.autorenew),
                      tooltip: "Random Password",
                      onPressed: () {
                        passwordCtrl.text = generatePassword();
                      },
                    ),
                  ],
                ),
              ),
              obscureText: !passwordVisible,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionCtrl,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: masterCtrl,
              decoration: InputDecoration(
                labelText: "Master Password",
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        masterVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => masterVisible = !masterVisible);
                      },
                    ),
                  ],
                ),
              ),
              obscureText: !masterVisible,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: updatePassword,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
