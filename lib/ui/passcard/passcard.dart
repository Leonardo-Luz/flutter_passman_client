import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_passman_client/models/passentry.dart';
import 'package:flutter_passman_client/ui/_core/app_colors.dart';
import 'package:flutter_passman_client/ui/edit/edit_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_passman_client/controllers/password_controller.dart';
import 'widgets/master_password_dialogue.dart';

class PassCard extends StatefulWidget {
  final String id;
  final String service;
  final String secret;
  final String description;

  const PassCard({
    super.key,
    required this.id,
    required this.service,
    required this.secret,
    required this.description,
  });

  @override
  State<PassCard> createState() => _PassCardState();
}

class _PassCardState extends State<PassCard> {
  bool expanded = false;
  bool loading = false;
  String? decryptedPass;
  String? masterTemp;

  Future<void> requestDecryption() async {
    final master = await askMasterPasswordDialog(context);
    if (master == null || master.isEmpty) return;

    if (!mounted) return;

    setState(() => loading = true);

    final controller = context.read<PasswordController>();

    final result = await controller.decryptPasswordForEntry(
      masterPassword: master,
      secret: widget.secret,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() => loading = false);

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

      return;
    }

    masterTemp = master;

    setState(() {
      decryptedPass = result;
      loading = false;
    });
  }

  Future<void> requestLock() async {
    if (!mounted) return;
    setState(() => loading = true);

    masterTemp = null;
    decryptedPass = null;

    setState(() {
      expanded = false;
      loading = false;
    });
  }

  Future<void> requestRemove() async {
    final master = await askMasterPasswordDialog(context);
    if (master == null || master.isEmpty) return;

    if (!mounted) return;

    setState(() => loading = true);

    final controller = context.read<PasswordController>();

    final result = await controller.decryptPasswordForEntry(
      masterPassword: master,
      secret: widget.secret,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() => loading = false);

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

      return;
    }

    await controller.delete(widget.id);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundBarColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.all(Radius.circular(12)),
            ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 15,
              children: [
                Icon(decryptedPass != null ? Icons.lock_open : Icons.lock),
                Text(widget.service, style: const TextStyle(fontSize: 18)),
              ],
            ),
            trailing: Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
            onTap: expanded
                ? requestLock
                : () => setState(() => expanded = !expanded),
          ),

          if (expanded)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (loading) const Center(child: CircularProgressIndicator()),

                  if (!loading && decryptedPass == null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.lock_open),
                          label: const Text("Unlock password"),
                          onPressed: requestDecryption,
                        ),
                      ],
                    ),

                  if (!loading && decryptedPass != null) ...[
                    const Text(
                      "Password:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(decryptedPass!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Description:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(widget.description),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          runSpacing: 8,
                          spacing: 8,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.delete),
                              label: const Text(
                                "Remove",
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: requestRemove,
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text(
                                "Edit",
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () => decryptedPass != null
                                  ? Navigator.pushNamed(
                                      context,
                                      EditScreen.route,
                                      arguments: PassEntry(
                                        id: widget.id,
                                        service: widget.service,
                                        secret: decryptedPass!,
                                        description: widget.description,
                                        master: masterTemp,
                                      ),
                                    )
                                  : null,
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.copy),
                              label: const Text(
                                "Copy",
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: decryptedPass != null
                                  ? () {
                                      Clipboard.setData(
                                        ClipboardData(text: decryptedPass!),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            spacing: 16,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color:
                                                    AppColors.backgroundColor,
                                              ),
                                              Text(
                                                "Password copied to clipboard!",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: AppColors.mainColor,
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
