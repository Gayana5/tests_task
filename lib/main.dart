import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/transaction_local_data_source.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'domain/repositories/transaction_repository.dart';
import 'ui/cubit/transaction_cubit.dart';
import 'ui/pages/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MoneyTrackerApp(prefs: prefs));
}

class MoneyTrackerApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MoneyTrackerApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: prefs),
        Provider<TransactionLocalDataSource>(
          create: (context) =>
              TransactionLocalDataSource(context.read<SharedPreferences>()),
        ),
        Provider<TransactionRepository>(
          create: (context) => TransactionRepositoryImpl(
            context.read<TransactionLocalDataSource>(),
          ),
        ),
      ],
      child: BlocProvider(
        create: (context) =>
            TransactionCubit(context.read<TransactionRepository>()),
        child: MaterialApp(
          title: 'Money Tracker',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
          ),
          home: const MainPage(),
        ),
      ),
    );
  }
}
