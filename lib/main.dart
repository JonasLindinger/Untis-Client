import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:untis_client/screens/LogInScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Base seeds for light and dark mode
    final baseLight = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple, // primary seed for light mode
      brightness: Brightness.light,
    );

    final baseDark = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple, // primary seed for dark mode
      brightness: Brightness.dark,
    );

    // Modern light scheme
    final lightScheme = baseLight.copyWith(
      primary: Colors.blueAccent,
      onPrimary: Colors.white,
      secondary: Colors.red.shade500,
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.grey.shade900,
      outline: Colors.grey.shade400,
      error: Colors.red.shade700,
      onError: Colors.white,
    );

    // Modern dark scheme
    final darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.blueAccent,
      onPrimary: Colors.black,
      secondary: Colors.red.shade900,
      onSecondary: Colors.black,
      surface: Color(0xFF111111),
      onSurface: Colors.grey.shade100,
      outline: Colors.grey.shade700,
      error: Colors.red.shade400,
      onError: Colors.black,
    );

    return MaterialApp(
      title: 'Untis Client',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
      ),
      themeMode: ThemeMode.system,
      home: const LogInScreen(),
    );
  }
}