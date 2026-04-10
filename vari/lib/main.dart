import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/admin_login_screen.dart';

void main() {
  runApp(const VariApp());
}

class VariApp extends StatelessWidget {
  const VariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vari Enterprise',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B),
          primary: const Color(0xFF00796B),
          secondary: const Color(0xFF26A69A),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.black87,
          ),
        ),
      ),
      home: kIsWeb ? const AdminLoginScreen() : const LoginScreen(),
    );
  }
}
