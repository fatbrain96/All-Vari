import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import '../services/api_config.dart';
import 'dashboard_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String ashaId;
  
  const ChangePasswordScreen({super.key, required this.ashaId});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordChange() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ashaId': widget.ashaId,
          'newPin': _newPinController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to dashboard after successful password change
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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

  String? _validateNewPin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new PIN';
    }
    if (value.length < 4) {
      return 'PIN must be at least 4 digits';
    }
    return null;
  }

  String? _validateConfirmPin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your PIN';
    }
    if (value != _newPinController.text) {
      return 'PINs do not match';
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
            
            // Header Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: FadeInDown(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "First Time Login",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Change Your PIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Please set a new secure PIN for your account",
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
            
            // Form Section
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
                          
                          // ASHA ID Display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.badge_outlined,
                                  color: Color(0xFF00796B),
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "ASHA ID",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      widget.ashaId,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          // NEW PIN FIELD
                          TextFormField(
                            controller: _newPinController,
                            validator: _validateNewPin,
                            obscureText: _obscureNewPassword,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "New PIN",
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF00796B),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
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
                          const SizedBox(height: 20),
                          
                          // CONFIRM PIN FIELD
                          TextFormField(
                            controller: _confirmPinController,
                            validator: _validateConfirmPin,
                            obscureText: _obscureConfirmPassword,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Confirm New PIN",
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF00796B),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
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
                          
                          // CHANGE PASSWORD BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handlePasswordChange,
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
                                      "Change PIN",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Security Notice
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Choose a secure PIN that you can remember. You'll use this to access your account.",
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
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