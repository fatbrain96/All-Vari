import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import '../widgets/custom_text_field.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  void _handleAdminLogin() {
    // Hardcoded secure gateway for presentation purposes
    if (idController.text == "ADMIN-HQ" && passController.text == "Waaree2026") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen())
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Unauthorized Access"),
          backgroundColor: Colors.red
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 60,
                color: Color(0xFF004D40)
              ),
              const SizedBox(height: 20),
              const Text(
                "Command Center Login",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 30),
              CustomTextField(
                label: "Admin ID",
                icon: Icons.badge,
                controller: idController
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: "Master Password",
                icon: Icons.lock,
                isPassword: true,
                controller: passController
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D40)
                  ),
                  onPressed: _handleAdminLogin,
                  child: const Text(
                    "Access Dashboard",
                    style: TextStyle(color: Colors.white, fontSize: 16)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}