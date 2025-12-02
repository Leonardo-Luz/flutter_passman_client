import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_passman_client/ui/_core/app_colors.dart';
import 'package:flutter_passman_client/ui/_core/widgets/appbar.dart';
import 'package:flutter_passman_client/ui/_core/widgets/bottombar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_passman_client/controllers/password_controller.dart';
import '../../utils/crypt.dart';

class OptionsScreen extends StatefulWidget {
  static const route = "/options";

  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  bool loading = false;

  Future<void> exportBackup() async {
    final controller = context.read<PasswordController>();
    final master = await _askMaster();
    if (master == null || master.isEmpty) return;

    setState(() => loading = true);

    final entries = controller.entries;

    final plain = entries
        .map((e) => "${e.id}|${e.service}|${e.secret}|${e.description ?? ""}")
        .join("\n");

    final encrypted = await encrypt(master, plain);

    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: "Export backup",
      fileName: "passman_backup.pmb",
    );

    if (outputPath != null) {
      final file = File(outputPath);
      await file.writeAsString(encrypted);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Icon(Icons.check_circle, color: AppColors.backgroundColor),
                Text(
                  "Backup exported!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: AppColors.mainColor,
          ),
        );
      }
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> importBackup() async {
    final controller = context.read<PasswordController>();
    final master = await _askMaster();
    if (master == null || master.isEmpty) return;

    final pick = await FilePicker.platform.pickFiles(
      dialogTitle: "Select backup file",
      type: FileType.any,
    );

    if (pick == null || pick.files.isEmpty) return;

    final path = pick.files.first.path;
    if (path == null) return;

    setState(() => loading = true);

    final encrypted = await File(path).readAsString();

    String decrypted;
    try {
      decrypted = await decrypt(master, encrypted);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Icon(Icons.remove_circle, color: AppColors.backgroundColor),
                Text(
                  "Invalid master password!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: AppColors.mainColor,
          ),
        );
      }
      if (mounted) setState(() => loading = false);
      return;
    }

    for (final line in decrypted.split("\n")) {
      if (line.trim().isEmpty) continue;

      final parts = line.split("|");
      if (parts.length < 3) continue;

      final id = parts[0];
      final service = parts[1];
      final secret = parts[2];
      final description = parts.length >= 4 ? parts[3] : "";

      // uses your controller API
      await controller.addRawPassword(
        id: id,
        service: service,
        secret: secret,
        description: description,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Icon(Icons.check_circle, color: AppColors.backgroundColor),
              Text(
                "Backup imported!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppColors.mainColor,
        ),
      );
      setState(() => loading = false);
    }
  }

  Future<String?> _askMaster() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Master Password"),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(hintText: "Enter master password"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: getAppBar(title: "Options"),
      bottomNavigationBar: getBottomBar(context, 2),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text("Export"),
                    onPressed: exportBackup,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload),
                    label: const Text("Import"),
                    onPressed: importBackup,
                  ),
                ],
              ),
      ),
    );
  }
}
