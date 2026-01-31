import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/transaction_item.dart';
import '../cubit/transaction_cubit.dart';
import 'add_transaction_page.dart';
import 'transaction_details_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().loadTransactions();
  }

  Future<void> _openAddTransaction() async {
    final result = await Navigator.of(context).push<TransactionItem>(
      MaterialPageRoute(builder: (_) => const AddTransactionPage()),
    );
    if (result != null && mounted) {
      await context.read<TransactionCubit>().addTransaction(result);
    }
  }

  void _openDetails(TransactionItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionDetailsPage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final filtered = state.filteredTransactions;
        final balance = state.balance;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Money Tracker'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openAddTransaction,
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('Balance', style: TextStyle(fontSize: 18)),
                        const Spacer(),
                        Text(
                          balance.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: balance >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    context.read<TransactionCubit>().setQuery(value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: state.filterType == FilterType.all,
                        onSelected: (_) {
                          context
                              .read<TransactionCubit>()
                              .setFilter(FilterType.all);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Income'),
                        selected: state.filterType == FilterType.income,
                        onSelected: (_) {
                          context
                              .read<TransactionCubit>()
                              .setFilter(FilterType.income);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Losses'),
                        selected: state.filterType == FilterType.losses,
                        onSelected: (_) {
                          context
                              .read<TransactionCubit>()
                              .setFilter(FilterType.losses);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No transactions'))
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return ListTile(
                              onTap: () => _openDetails(item),
                              title: Text(item.name),
                              subtitle: Text(
                                '${item.category} • ${item.date.toLocal().toString().split(' ').first}',
                              ),
                              trailing: Text(
                                (item.isIncome ? '+' : '-') +
                                    item.amount.toStringAsFixed(2),
                                style: TextStyle(
                                  color:
                                      item.isIncome ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
