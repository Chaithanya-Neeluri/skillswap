// lib/features/wallet/data/wallet_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletService {
  static const String BASE_URL = 'https://your-express-backend.com/api/wallet'; // <-- change
  final _db = FirebaseFirestore.instance;

  /// Stream for real-time updates of user's wallet transactions
  Stream<List<Map<String, dynamic>>> transactionStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('wallet_transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  /// Fetch wallet balance from backend (ensures secure and consistent)
  Future<int> fetchBalance(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');
    final res = await http.get(
      Uri.parse('$BASE_URL/balance/$uid'),
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['points'] ?? 0;
    } else {
      throw Exception('Failed to fetch wallet balance: ${res.body}');
    }
  }

  /// Add points (e.g., when user teaches something)
  Future<void> addPoints(String uid, int points, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');

    final res = await http.post(
      Uri.parse('$BASE_URL/add'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'uid': uid, 'points': points, 'reason': reason}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to add points: ${res.body}');
    }
  }

  /// Redeem points (for rewards or achievements)
  Future<void> redeemPoints(String uid, int points, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');

    final res = await http.post(
      Uri.parse('$BASE_URL/redeem'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'uid': uid, 'points': points, 'reason': reason}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to redeem points: ${res.body}');
    }
  }
}
