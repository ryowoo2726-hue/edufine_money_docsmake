import 'package:flutter/material.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/main_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, child) {
        return MaterialApp(
          title: '학교 품의서 생성기',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: MainLayout(state: _appState),
        );
      },
    );
  }
}
