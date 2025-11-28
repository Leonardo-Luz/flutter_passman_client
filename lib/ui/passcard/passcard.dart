import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid master password!")));

      return;
    }

    setState(() {
      decryptedPass = result;
      loading = false;
    });
  }

  Future<void> requestLock() async {
    if (!mounted) return;
    setState(() => loading = true);

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid master password!")));

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
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

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
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
                        ),

                        Row(
                          spacing: 8,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.delete),
                              label: const Text("Remove"),
                              onPressed: requestRemove,
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text("Edit"),
                              onPressed: () {},
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.copy),
                              label: const Text("Copy"),
                              onPressed: decryptedPass != null
                                  ? () {
                                      Clipboard.setData(
                                        ClipboardData(text: decryptedPass!),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Password copied to clipboard!",
                                          ),
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
