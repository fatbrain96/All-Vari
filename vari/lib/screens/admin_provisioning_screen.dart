import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_config.dart';

class AdminProvisioningScreen extends StatefulWidget {
  const AdminProvisioningScreen({super.key});

  @override
  State<AdminProvisioningScreen> createState() => _AdminProvisioningScreenState();
}

class _AdminProvisioningScreenState extends State<AdminProvisioningScreen> {
  // Text Controllers
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _village = TextEditingController();
  final TextEditingController _mobile = TextEditingController();

  // State Management
  List<Map<String, dynamic>> _recentWorkers = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _village.dispose();
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _registerWorker() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/workers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': _firstName.text,
          'lastName': _lastName.text,
          'village': _village.text,
          'phone': _mobile.text,
        }),
      );

      if (response.statusCode == 200) {
        final newWorker = jsonDecode(response.body);
        
        setState(() {
          _recentWorkers.insert(0, newWorker);
        });

        // Clear text controllers
        _firstName.clear();
        _lastName.clear();
        _village.clear();
        _mobile.clear();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Worker Provisioned Successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to register worker');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Provisioning'),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section - The Form
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Register New ASHA Worker',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // First Name Field
                    TextFormField(
                      controller: _firstName,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Last Name Field
                    TextFormField(
                      controller: _lastName,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Village Field
                    TextFormField(
                      controller: _village,
                      decoration: const InputDecoration(
                        labelText: 'Village',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Mobile Field
                    TextFormField(
                      controller: _mobile,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerWorker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00796B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Generate & Register',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Bottom Section - Data Table
            const Text(
              'Recently Provisioned Workers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentWorkers.length,
              itemBuilder: (context, index) {
                final worker = _recentWorkers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker['ashaId'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00796B),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'PIN: ${worker['pin'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          worker['name'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Village: ${worker['assignedVillage'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}