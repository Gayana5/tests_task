import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';

enum FilterType { all, income, losses }

class TransactionState extends Equatable {
  final List<TransactionItem> transactions;
  final FilterType filterType;
  final String query;

  const TransactionState({
    required this.transactions,
    required this.filterType,
    required this.query,
  });

  TransactionState copyWith({
    List<TransactionItem>? transactions,
    FilterType? filterType,
    String? query,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      filterType: filterType ?? this.filterType,
      query: query ?? this.query,
    );
  }

  double get balance {
    double total = 0;
    for (final t in transactions) {
      total += t.isIncome ? t.amount : -t.amount;
    }
    return total;
  }

  List<TransactionItem> get filteredTransactions {
    final q = query.trim().toLowerCase();
    return transactions.where((t) {
      final matchesFilter = filterType == FilterType.all ||
          (filterType == FilterType.income && t.isIncome) ||
          (filterType == FilterType.losses && !t.isIncome);
      final matchesQuery = q.isEmpty ||
          t.name.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  @override
  List<Object> get props => [transactions, filterType, query];
}

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository repository;

  TransactionCubit(this.repository)
      : super(const TransactionState(
          transactions: [],
          filterType: FilterType.all,
          query: '',
        ));

  Future<void> loadTransactions() async {
    final items = await repository.loadTransactions();
    emit(state.copyWith(transactions: items));
  }

  Future<void> addTransaction(TransactionItem item) async {
    final updated = [item, ...state.transactions];
    emit(state.copyWith(transactions: updated));
    await repository.saveTransactions(updated);
  }

  void setFilter(FilterType type) {
    emit(state.copyWith(filterType: type));
  }

  void setQuery(String value) {
    emit(state.copyWith(query: value));
  }
}
