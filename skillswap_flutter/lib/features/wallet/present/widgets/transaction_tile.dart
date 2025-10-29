// lib/features/wallet/presentation/widgets/transaction_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const TransactionTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isAdd = (data['type'] ?? '') == 'add';
    final timestamp = data['timestamp']?.toDate() ?? DateTime.now();

    return ListTile(
      leading: Icon(isAdd ? Icons.arrow_upward : Icons.arrow_downward,
          color: isAdd ? Colors.green : Colors.red),
      title: Text(data['reason'] ?? 'Unknown'),
      subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(timestamp)),
      trailing: Text(
        "${isAdd ? '+' : '-'}${data['points'] ?? 0}",
        style: TextStyle(
          color: isAdd ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
