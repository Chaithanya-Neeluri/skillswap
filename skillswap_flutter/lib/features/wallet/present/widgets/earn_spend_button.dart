import 'package:flutter/material.dart';

class EarnSpendButtons extends StatelessWidget {
  final VoidCallback onEarn;
  final VoidCallback onSpend;
  const EarnSpendButtons({super.key, required this.onEarn, required this.onSpend});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text("Earn Points"),
          onPressed: onEarn,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.card_giftcard),
          label: const Text("Redeem"),
          onPressed: onSpend,
        ),
      ],
    );
  }
}
