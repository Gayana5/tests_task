import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl(this.localDataSource);

  @override
  Future<List<TransactionItem>> loadTransactions() async {
    final models = localDataSource.loadTransactions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveTransactions(List<TransactionItem> transactions) async {
    final models =
        transactions.map(TransactionModel.fromEntity).toList();
    await localDataSource.saveTransactions(models);
  }
}
