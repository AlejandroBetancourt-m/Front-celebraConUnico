import 'package:flutter/material.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const CelebraUnicoApp());
}

class CelebraUnicoApp extends StatelessWidget {
  const CelebraUnicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seedGreen = const Color(0xFF0F9D58); // verde principal

    return MaterialApp(
      title: 'Celebra Único',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedGreen,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F7F5),
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: seedGreen, width: 1.3),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
