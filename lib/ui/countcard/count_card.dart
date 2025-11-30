import 'package:flutter/material.dart';
import 'package:flutter_passman_client/ui/_core/app_colors.dart';

class CountCard extends StatelessWidget {
  final String title;
  final int? count;
  final IconData icon;

  const CountCard({
    super.key,
    required this.title,
    this.count,
    this.icon = Icons.info,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundBarColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 15,
          children: [
            Icon(icon),
            Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
        trailing: Text(count.toString(), style: const TextStyle(fontSize: 25)),
      ),
    );
  }
}
