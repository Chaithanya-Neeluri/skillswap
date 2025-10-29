// lib/features/wallet/presentation/transaction_history_screen.dart
import 'package:flutter/material.dart';
import '../../wallet/data/wallet_service.dart';
import 'widgets/transaction_tile.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final String uid;
  final WalletService _service = WalletService();

  TransactionHistoryScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _service.transactionStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final txs = snapshot.data ?? [];
          if (txs.isEmpty) {
            return const Center(child: Text("No transactions yet"));
          }
          return ListView.builder(
            itemCount: txs.length,
            itemBuilder: (_, i) => TransactionTile(data: txs[i]),
          );
        },
      ),
    );
  }
}
