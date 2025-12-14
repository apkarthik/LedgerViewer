import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'screens/home_screen.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const LedgerViewApp(),
    ),
  );
}

class LedgerViewApp extends StatelessWidget {
  const LedgerViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'LedgerView',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          home: const MainScreen(),
          routes: {
            '/ledger': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}
