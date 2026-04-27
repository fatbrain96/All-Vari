import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../services/api_config.dart';
import 'mobile_map_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  bool isLoading = false;
  
  // Dashboard stats - now fetched from backend
  int _totalSamples = 0;
  int _criticalZones = 0;
  int _activePatients = 0;
  
  // Real data for Recent Field Reports
  List<dynamic> _recentReports = [];
  bool _isLoadingReports = true;
  
  // New state variables for ASHA workers
  List<dynamic> _ashaWorkers = [];
  bool _isLoadingWorkers = true;
  
  // Auto-refresh timer
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchReports();
    _fetchWorkers();
    
    // Auto-refresh reports every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchReports();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  Future<void> _fetchReports() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/reports'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _recentReports = data;
          // Update total samples count from actual reports
          _totalSamples = data.length;
          
          // Calculate critical zones (reports with unsafe status)
          _criticalZones = data.where((r) => r['status'] != 'Safe').length;
          
          // Calculate active patients (sum of victims across all reports)
          _activePatients = 0;
          for (var report in data) {
            final victims = (report['victims'] as List?)?.length ?? 0;
            _activePatients += victims;
          }
        });
      }
    } catch (e) {
      ApiConfig.logError('/reports', e);
    } finally {
      setState(() => _isLoadingReports = false);
    }
  }

  Future<void> _fetchWorkers() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/admin/workers'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _ashaWorkers = data;
          _isLoadingWorkers = false;
        });
      }
    } catch (e) {
      ApiConfig.logError('/admin/workers', e);
      setState(() => _isLoadingWorkers = false);
    }
  }

  void _showProvisionDialog() {
    showDialog(
      context: context,
      builder: (context) => _ProvisionDialog(
        onWorkerCreated: _fetchWorkers, // Pass callback to refresh workers
      ),
    );
  }

  void _showPatientDetails(Map<String, dynamic> report) {
    final victims = (report['victims'] as List?) ?? [];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report #${report['id']} - Patients'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ASHA ID: ${report['ashaId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Date: ${report['createdAt']?.toString().split('T')[0] ?? 'N/A'}'),
              const SizedBox(height: 15),
              if (victims.isEmpty)
                const Text('No patients recorded', style: TextStyle(color: Colors.grey))
              else
                ...victims.map((victim) => Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${victim['name'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Age: ${victim['age'] ?? 'N/A'}'),
                      Text('Gender: ${victim['gender'] ?? 'N/A'}'),
                      Text('Disease: ${victim['disease'] ?? 'N/A'}'),
                      Text('Duration: ${victim['duration'] ?? 'N/A'}'),
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          '📷 Patient images are stored locally on ASHA worker devices',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color.fromARGB(255, 53, 233, 233),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF00796B),
              ),
              child: Text(
                'Vari Admin Portal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Command Center'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('ASHA Personnel'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('District Heatmap'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MobileMapScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE8F4F8),
              Color(0xFFE0F2F1),
            ],
          ),
        ),
        child: _selectedIndex == 0 ? _buildCommandCenterView() : _buildAshaPersonnelView(),
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: _showProvisionDialog,
              backgroundColor: const Color(0xFF00796B),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Worker'),
            )
          : null,
    );
  }

  Widget _buildCommandCenterView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Command Center",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00695C)
            )
          ),
          const Text(
            "District-wide Water & Health Surveillance",
            style: TextStyle(color: Color(0xFF5A8A88), fontSize: 16)
          ),
          const SizedBox(height: 30),
          // STATS ROW
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Total Samples",
                  _totalSamples.toString(),
                  Icons.science,
                  Colors.blue
                )
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatCard(
                  "Critical Zones",
                  _criticalZones.toString(),
                  Icons.warning,
                  Colors.red
                )
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatCard(
                  "Active Patients",
                  _activePatients.toString(),
                  Icons.personal_injury,
                  Colors.orange
                )
              ),
            ],
          ),
          const SizedBox(height: 40),
          // RECENT FIELD REPORTS TABLE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade200, blurRadius: 10)
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Recent Field Reports",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00695C)
                  )
                ),
                const SizedBox(height: 15),
                _isLoadingReports
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _recentReports.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                "No field reports available",
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('ASHA ID')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('GPS Location')),
                                DataColumn(label: Text('pH Level')),
                                DataColumn(label: Text('TDS (ppm)')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Patients')),
                              ],
                              rows: _recentReports.map((r) {
                                final isSafe = r['status'] == 'Safe';
                                final victims = (r['victims'] as List?)?.length ?? 0;
                                final date = r['createdAt']?.toString().split('T')[0] ?? 'N/A';
                                
                                return DataRow(
                                  onSelectChanged: (_) => _showPatientDetails(r),
                                  cells: [
                                    DataCell(Text("#${r['id']}")),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          r['ashaId'] ?? 'N/A',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(date)),
                                    DataCell(Text("${r['latitude']}, ${r['longitude']}")),
                                    DataCell(Text("${r['phLevel']}")),
                                    DataCell(Text("${r['tdsLevel']}")),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isSafe ? Colors.green.shade50 : Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(20)
                                        ),
                                        child: Text(
                                          r['status'],
                                          style: TextStyle(
                                            color: isSafe ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold
                                          )
                                        ),
                                      )
                                    ),
                                    DataCell(
                                      Text(
                                        victims > 0 ? "🏥 $victims" : "-",
                                        style: TextStyle(
                                          color: victims > 0 ? Colors.orange : Colors.grey,
                                          fontWeight: FontWeight.bold
                                        )
                                      )
                                    ),
                                  ]
                                );
                              }).toList(),
                            ),
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAshaPersonnelView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Active ASHA Personnel",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00695C)
            )
          ),
          const Text(
            "Manage and monitor registered ASHA workers",
            style: TextStyle(color: Color(0xFF5A8A88), fontSize: 16)
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade200, blurRadius: 10)
              ]
            ),
            child: _isLoadingWorkers
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Registered Workers (${_ashaWorkers.length})",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00695C)
                        )
                      ),
                      const SizedBox(height: 15),
                      _ashaWorkers.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  "No ASHA workers registered yet",
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'ASHA ID',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Full Name',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Age',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Assigned Village',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Block',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Mobile',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Secure PIN',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: _ashaWorkers.map((worker) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              worker['ashaId'] ?? 'N/A',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(worker['name'] ?? 'N/A')),
                                        DataCell(Text(worker['age']?.toString() ?? 'N/A')),
                                        DataCell(Text(worker['assignedVillage'] ?? 'N/A')),
                                        DataCell(Text(worker['block'] ?? 'N/A')),
                                        DataCell(Text(worker['phone'] ?? 'N/A')),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              worker['pin'] ?? 'N/A',
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red.shade700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3))
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 30)
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color
                )
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold
                )
              ),
            ],
          )
        ],
      ),
    );
  }

}

class _ProvisionDialog extends StatefulWidget {
  final VoidCallback? onWorkerCreated;
  
  const _ProvisionDialog({this.onWorkerCreated});

  @override
  State<_ProvisionDialog> createState() => _ProvisionDialogState();
}

class _ProvisionDialogState extends State<_ProvisionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  
  bool _isLoading = false;
  Map<String, dynamic>? _generatedWorker;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _villageController.dispose();
    _mobileController.dispose();
    _ageController.dispose();
    _blockController.dispose();
    super.dispose();
  }

  Future<void> _registerWorker() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/workers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'village': _villageController.text.trim(),
          'phone': _mobileController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()),
          'block': _blockController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final newWorker = jsonDecode(response.body);
        
        setState(() {
          _generatedWorker = newWorker;
          // Clear form
          _firstNameController.clear();
          _lastNameController.clear();
          _villageController.clear();
          _mobileController.clear();
          _ageController.clear();
          _blockController.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Worker Provisioned Successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Call the callback to refresh the workers table
          if (widget.onWorkerCreated != null) {
            widget.onWorkerCreated!();
          }
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

  String? _validateField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Register ASHA Worker'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_generatedWorker != null) ...[
                // Success Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✅ Worker Generated Successfully!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('ASHA ID: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: SelectableText(
                              _generatedWorker!['ashaId'] ?? 'N/A',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('PIN: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: SelectableText(
                              _generatedWorker!['pin'] ?? 'N/A',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Name: ${_generatedWorker!['name'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        'Village: ${_generatedWorker!['assignedVillage'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      validator: _validateField,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      validator: _validateField,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _villageController,
                      validator: _validateField,
                      decoration: const InputDecoration(
                        labelText: 'Village',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mobileController,
                      validator: _validateField,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      validator: _validateField,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _blockController,
                      validator: _validateField,
                      decoration: const InputDecoration(
                        labelText: 'Block / Tehsil',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _registerWorker,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00796B),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Generate & Register'),
        ),
      ],
    );
  }
}