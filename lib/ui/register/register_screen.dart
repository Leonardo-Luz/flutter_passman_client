import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_passman_client/controllers/password_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_passman_client/ui/_core/app_colors.dart';
import 'package:flutter_passman_client/ui/_core/widgets/appbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const route = "/register";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final serviceCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final masterCtrl = TextEditingController();
  bool passwordVisible = false;

  @override
  void dispose() {
    serviceCtrl.dispose();
    passwordCtrl.dispose();
    descriptionCtrl.dispose();
    masterCtrl.dispose();
    super.dispose();
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

  Future<void> getPasswordFile() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: getAppBar(title: 'Add New Password'),
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
                      onPressed: getPasswordFile,
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
              decoration: const InputDecoration(labelText: "Master Password"),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final svc = serviceCtrl.text.trim();
                final pwd = passwordCtrl.text.trim();
                final desc = descriptionCtrl.text.trim();
                final master = masterCtrl.text.trim();

                if (svc.isEmpty || pwd.isEmpty || master.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Service, password and master password are required!",
                      ),
                    ),
                  );
                  return;
                }

                final controller = context.read<PasswordController>();
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                try {
                  await controller.addPassword(
                    service: svc,
                    masterPassword: master,
                    plainPassword: pwd,
                    description: desc,
                  );
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error saving: $e')),
                  );
                  return;
                }

                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text("Password saved!")),
                );
                navigator.pop();
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
