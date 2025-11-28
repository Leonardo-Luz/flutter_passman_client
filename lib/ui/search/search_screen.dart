import 'package:flutter/material.dart';
import 'package:flutter_passman_client/ui/passcard/passcard.dart';
import 'package:provider/provider.dart';
import 'package:flutter_passman_client/ui/_core/app_colors.dart';
import 'package:flutter_passman_client/ui/_core/widgets/appbar.dart';
import 'package:flutter_passman_client/controllers/password_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  static const route = "/search";

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController query = TextEditingController();
  List filteredEntries = [];
  bool searching = false;

  void runSearch() {
    final q = query.text.trim().toLowerCase();
    final controller = context.read<PasswordController>();
    setState(() {
      searching = true;
      filteredEntries = controller.entries
          .where((e) => e.service.toLowerCase().contains(q))
          .toList();
      searching = false;
    });
  }

  void cleanSearch() {
    final controller = context.read<PasswordController>();
    setState(() {
      filteredEntries = List.from(controller.entries);
    });
  }

  @override
  void initState() {
    super.initState();
    final controller = context.read<PasswordController>();
    filteredEntries = List.from(controller.entries);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PasswordController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: getAppBar(title: 'Search Password'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: query,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Service',
                labelStyle: const TextStyle(color: Colors.white70),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white70),
                  onPressed: runSearch,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withAlpha(90)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              onSubmitted: (_) => runSearch(),
            ),
            const SizedBox(height: 20),
            if (searching || controller.loading)
              const Center(child: CircularProgressIndicator(color: Colors.white))
            else if (filteredEntries.isEmpty)
              const Text(
                "Nenhum resultado encontrado.",
                style: TextStyle(color: Colors.white70),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, i) {
                    final e = filteredEntries[i];
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
          ],
        ),
      ),
    );
  }
}
