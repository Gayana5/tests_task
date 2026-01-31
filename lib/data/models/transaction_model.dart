import '../../domain/entities/transaction_item.dart';

class TransactionModel {
  final DateTime date;
  final String category;
  final String name;
  final double amount;
  final bool isIncome;

  const TransactionModel({
    required this.date,
    required this.category,
    required this.name,
    required this.amount,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'name': name,
      'amount': amount,
      'isIncome': isIncome,
    };
  }

  static TransactionModel fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      category: map['category'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      isIncome: map['isIncome'] as bool,
    );
  }

  TransactionItem toEntity() {
    return TransactionItem(
      date: date,
      category: category,
      name: name,
      amount: amount,
      isIncome: isIncome,
    );
  }

  static TransactionModel fromEntity(TransactionItem item) {
    return TransactionModel(
      date: item.date,
      category: item.category,
      name: item.name,
      amount: item.amount,
      isIncome: item.isIncome,
    );
  }
}
