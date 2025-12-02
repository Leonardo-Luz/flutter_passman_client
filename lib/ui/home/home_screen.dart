import 'package:flutter/material.dart';
import 'package:flutter_passman_client/ui/countcard/count_card.dart';
import 'package:flutter_passman_client/ui/register/register_screen.dart';
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
          : Padding(
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 70,
                left: 16,
                right: 16,
              ),
              child: ListView.builder(
                itemCount: controller.entries.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return CountCard(
                      count: controller.getPasswordsQty(),
                      title: "Passwords",
                      icon: Icons.key,
                    );
                  }

                  final e = controller.entries[i - 1];
                  return PassCard(
                    key: ValueKey(e.id),
                    id: e.id,
                    service: e.service,
                    secret: e.secret,
                    description: e.description ?? "-",
                  );
                },
              ),
            ),
      bottomSheet: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, RegisterScreen.route),
            icon: const Icon(Icons.add, size: 22),
            label: const Text(
              "Add new Password",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
