import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_passman_client/controllers/password_controller.dart';
import 'package:flutter_passman_client/ui/_core/app_colors.dart';
import 'package:flutter_passman_client/ui/_core/widgets/appbar.dart';
import 'package:flutter_passman_client/ui/_core/widgets/bottombar.dart';
import 'package:flutter_passman_client/ui/passcard/passcard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const route = "/home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PasswordController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: getAppBar(title: 'Passman'),
      bottomNavigationBar: getBottomBar(context, 1),

      body: controller.loading
          ? const Center(child: CircularProgressIndicator())
          : controller.entries.isEmpty
          ? const Center(
              child: Text("No passwords yet", style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              itemCount: controller.entries.length,
              itemBuilder: (_, i) {
                final e = controller.entries[i];
                return PassCard(
                  key: ValueKey(e.id),
                  id: e.id,
                  service: e.service,
                  secret: e.secret,
                  description: e.description ?? "-",
                );
              },
            ),
    );
  }
}
