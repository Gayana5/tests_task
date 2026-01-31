import 'package:flutter_test/flutter_test.dart';

import 'package:tests_task/domain/entities/transaction_item.dart';
import 'package:tests_task/domain/repositories/transaction_repository.dart';
import 'package:tests_task/ui/cubit/transaction_cubit.dart';

class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository({List<TransactionItem>? initial})
      : _items = List.of(initial ?? []);

  final List<TransactionItem> _items;
  List<TransactionItem> lastSaved = [];

  @override
  Future<List<TransactionItem>> loadTransactions() async {
    return List.of(_items);
  }

  @override
  Future<void> saveTransactions(List<TransactionItem> transactions) async {
    lastSaved = List.of(transactions);
    _items
      ..clear()
      ..addAll(transactions);
  }
}

TransactionItem _item({
  required String name,
  required String category,
  required double amount,
  required bool isIncome,
}) {
  return TransactionItem(
    date: DateTime(2024, 1, 1),
    category: category,
    name: name,
    amount: amount,
    isIncome: isIncome,
  );
}

void main() {
  test('addTransaction inserts item at top and persists', () async {
    final repo = FakeTransactionRepository();
    final cubit = TransactionCubit(repo);

    final item = _item(
      name: 'Salary',
      category: 'Work',
      amount: 2000,
      isIncome: true,
    );

    await cubit.addTransaction(item);

    expect(cubit.state.transactions.first, item);
    expect(cubit.state.transactions.length, 1);
    expect(repo.lastSaved.length, 1);
    expect(repo.lastSaved.first, item);
  });

  test('filter shows only income or losses', () async {
    final income = _item(
      name: 'Salary',
      category: 'Work',
      amount: 2000,
      isIncome: true,
    );
    final loss = _item(
      name: 'Rent',
      category: 'Home',
      amount: 500,
      isIncome: false,
    );

    final repo = FakeTransactionRepository(initial: [income, loss]);
    final cubit = TransactionCubit(repo);
    await cubit.loadTransactions();

    cubit.setFilter(FilterType.income);
    expect(cubit.state.filteredTransactions, [income]);

    cubit.setFilter(FilterType.losses);
    expect(cubit.state.filteredTransactions, [loss]);

    cubit.setFilter(FilterType.all);
    expect(cubit.state.filteredTransactions, [income, loss]);
  });

  test('search matches name or category', () async {
    final groceries = _item(
      name: 'Groceries',
      category: 'Food',
      amount: 120,
      isIncome: false,
    );
    final cafe = _item(
      name: 'Coffee',
      category: 'Cafe',
      amount: 6,
      isIncome: false,
    );

    final repo = FakeTransactionRepository(initial: [groceries, cafe]);
    final cubit = TransactionCubit(repo);
    await cubit.loadTransactions();

    cubit.setQuery('gro');
    expect(cubit.state.filteredTransactions, [groceries]);

    cubit.setQuery('caf');
    expect(cubit.state.filteredTransactions, [cafe]);
  });

  test('search and filter are combined and case-insensitive', () async {
    final incomeMatch = _item(
      name: 'Bonus',
      category: 'Work',
      amount: 300,
      isIncome: true,
    );
    final incomeOther = _item(
      name: 'Gift',
      category: 'Friends',
      amount: 50,
      isIncome: true,
    );
    final lossMatch = _item(
      name: 'Bonus',
      category: 'Fun',
      amount: 30,
      isIncome: false,
    );

    final repo = FakeTransactionRepository(
      initial: [incomeMatch, incomeOther, lossMatch],
    );
    final cubit = TransactionCubit(repo);
    await cubit.loadTransactions();

    cubit.setFilter(FilterType.income);
    cubit.setQuery('  bon  ');
    expect(cubit.state.filteredTransactions, [incomeMatch]);
  });
}
