import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';

class TransactionLocalDataSource {
  static const String _prefsKey = 'transactions';
  final SharedPreferences prefs;

  TransactionLocalDataSource(this.prefs);

  List<TransactionModel> loadTransactions() {
    final stored = prefs.getStringList(_prefsKey) ?? [];
    return stored
        .map((raw) => TransactionModel.fromMap(
            jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final stored =
        transactions.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList(_prefsKey, stored);
  }
}
