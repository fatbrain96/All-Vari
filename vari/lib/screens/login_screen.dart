import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_config.dart';
import 'dashboard_screen.dart';
import 'change_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ashaIdController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _ashaIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // Handle login authentication
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ashaId': _ashaIdController.text.trim(),
          'pin': _pinController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final responseData = jsonDecode(response.body);
        
        // Debug: Print response data to see what the backend is sending
        print('DEBUG: Response Data: $responseData');
        
        // Save user session data
        final prefs = await SharedPreferences.getInstance();
        
        // Store worker information for profile screen
        await prefs.setString('ashaId', responseData['ashaId'] ?? '');
        await prefs.setString('workerName', responseData['name'] ?? '');
        await prefs.setString('assignedVillage', responseData['assignedVillage'] ?? '');
        await prefs.setString('workerPhone', responseData['phone'] ?? '');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Check if this is the user's first login
          bool isFirstLogin = responseData['firstLogin'] == true || responseData['isFirstLogin'] == true;
          
          if (isFirstLogin) {
            print('DEBUG: First login detected. Redirecting to Change Password.');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChangePasswordScreen(ashaId: responseData['ashaId']),
              ),
            );
          } else {
            print('DEBUG: Not a first login. Proceeding to Dashboard.');
            // Navigate to main dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()), 
            );
          }
        }
      } else {
        throw Exception('Invalid Credentials');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF004D40),
              Color(0xFF00796B),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            
            // Header section with app branding
            Padding(
              padding: const EdgeInsets.all(20),
              child: FadeInDown(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Welcome Back,",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Vari Field Connect",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Secure Healthcare Data Platform",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 🎨 ANIMATED BOTTOM CARD WITH FORM
            Expanded(
              child: FadeInUp(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          
                          // ASHA ID FIELD
                          TextFormField(
                            controller: _ashaIdController,
                            validator: _validateField,
                            decoration: InputDecoration(
                              labelText: "ASHA ID",
                              prefixIcon: const Icon(
                                Icons.badge_outlined,
                                color: Color(0xFF00796B),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00796B),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: Colors.red, width: 2),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: Colors.red, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // SECURE PIN FIELD
                          TextFormField(
                            controller: _pinController,
                            validator: _validateField,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Secure PIN",
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF00796B),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00796B),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: Colors.red, width: 2),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: Colors.red, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          // SMART LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00796B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      "Access Dashboard",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // FOOTER
                          const Text(
                            "Powered by Ministry of Health & Vari Tech",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}