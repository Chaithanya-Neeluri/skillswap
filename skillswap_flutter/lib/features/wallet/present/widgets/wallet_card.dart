import 'package:flutter/material.dart';

class WalletCard extends StatelessWidget {
  final int points;
  const WalletCard({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Your Balance", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              "$points Points",
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
