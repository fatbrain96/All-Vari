import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_text_field.dart';
import '../services/api_config.dart';

class WaterReportScreen
    extends
        StatefulWidget {
  const WaterReportScreen({
    super.key,
  });

  @override
  State<
    WaterReportScreen
  >
  createState() => _WaterReportScreenState();
}

class _WaterReportScreenState
    extends
        State<
          WaterReportScreen
        > {
  int _currentStep = 0;

  // Controllers for Water Data
  final TextEditingController phController = TextEditingController();
  final TextEditingController tdsController = TextEditingController();
  final TextEditingController turbController = TextEditingController();

  // Location Data
  double? currentLat;
  double? currentLong;
  bool isLocationFound = false;
  bool isSubmitting = false;
  
  // ASHA Worker ID
  String _ashaId = "UNKNOWN";

  // 🏥 Victim Data List
  List<
    Map<
      String,
      dynamic
    >
  >
  _victims = [];

  @override
  void initState() {
    super.initState();
    _getLocation();
    _loadAshaId();
  }
  
  Future<void> _loadAshaId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ashaId = prefs.getString('ashaId') ?? 'UNKNOWN';
    });
  }

  Future<
    void
  >
  _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission ==
          LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(
        () {
          currentLat = position.latitude;
          currentLong = position.longitude;
          isLocationFound = true;
        },
      );
    } catch (
      e
    ) {
      ApiConfig.logError('/location', e);
    }
  }

  // 🏥 ENHANCED: Function to Add Victim via Dialog with Medical Details + Image
  void _showAddVictimDialog() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final weightController = TextEditingController();
    final contactController = TextEditingController();
    final daysController = TextEditingController();
    final medsNameController = TextEditingController();
    String selectedGender = 'Male';
    String selectedCondition = 'Diarrhea';
    bool hasMeds = false;

    // ✅ NEW: Image capture variables
    XFile? _imageFile;
    final ImagePicker _picker = ImagePicker();

    Future<
      void
    >
    _pickImage(
      StateSetter updateState,
    ) async {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 300, // ✅ Reduced from 400 to 300
        imageQuality: 40, // ✅ Reduced from 60 to 40 for smaller file size
      );
      if (photo != null) {
        updateState(
          () {
            _imageFile = photo;
          },
        );
      }
    }

    showDialog(
      context: context,
      builder:
          (
            context,
          ) => StatefulBuilder(
            builder:
                (
                  context,
                  setDialogState,
                ) {
                  return AlertDialog(
                    title: const Text(
                      "🏥 Patient Details",
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✅ NEW: Patient Photo Section
                          Center(
                            child: GestureDetector(
                              onTap: () => _pickImage(
                                setDialogState,
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.teal.shade50,
                                backgroundImage:
                                    _imageFile !=
                                        null
                                    ? FileImage(
                                        File(
                                          _imageFile!.path,
                                        ),
                                      )
                                    : null,
                                child:
                                    _imageFile ==
                                        null
                                    ? const Icon(
                                        Icons.camera_alt,
                                        size: 30,
                                        color: Colors.teal,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Center(
                            child: Text(
                              "Tap to take photo",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),

                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: "Full Name",
                              prefixIcon: Icon(
                                Icons.person,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: ageController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Age",
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Weight (kg)",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: contactController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: "Contact Number",
                              prefixIcon: Icon(
                                Icons.phone,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: daysController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Days since symptoms started",
                              prefixIcon: Icon(
                                Icons.calendar_today,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButtonFormField<
                            String
                          >(
                            value: selectedGender,
                            items:
                                [
                                      'Male',
                                      'Female',
                                      'Other',
                                    ]
                                    .map(
                                      (
                                        e,
                                      ) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (
                                  v,
                                ) => setDialogState(
                                  () => selectedGender = v!,
                                ),
                            decoration: const InputDecoration(
                              labelText: "Gender",
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButtonFormField<
                            String
                          >(
                            value: selectedCondition,
                            items:
                                [
                                      'Diarrhea',
                                      'Typhoid',
                                      'Jaundice',
                                      'Fever',
                                      'Skin Rash',
                                    ]
                                    .map(
                                      (
                                        e,
                                      ) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (
                                  v,
                                ) => setDialogState(
                                  () => selectedCondition = v!,
                                ),
                            decoration: const InputDecoration(
                              labelText: "Condition",
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // Medication Toggle
                          SwitchListTile(
                            title: const Text(
                              "Prior Medication?",
                            ),
                            value: hasMeds,
                            onChanged:
                                (
                                  val,
                                ) => setDialogState(
                                  () => hasMeds = val,
                                ),
                          ),
                          if (hasMeds)
                            TextField(
                              controller: medsNameController,
                              decoration: const InputDecoration(
                                labelText: "Medicine Name",
                                prefixIcon: Icon(
                                  Icons.medication,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(
                          context,
                        ),
                        child: const Text(
                          "Cancel",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isNotEmpty) {
                            // ✅ Convert image to Base64 for database storage
                            String base64Image = "";
                            if (_imageFile != null) {
                              List<int> imageBytes = await File(_imageFile!.path).readAsBytes();
                              base64Image = base64Encode(imageBytes);
                              
                              // ✅ Limit base64 size to 100KB to avoid server errors
                              if (base64Image.length > 100000) {
                                setDialogState(() {
                                  base64Image = base64Image.substring(0, 100000);
                                });
                              }
                            }

                            // Add to parent list with enhanced medical data + base64 image
                            setState(
                              () {
                                _victims.add(
                                  {
                                    "name": nameController.text,
                                    "age":
                                        int.tryParse(
                                          ageController.text,
                                        ) ??
                                        0,
                                    "weight":
                                        double.tryParse(
                                          weightController.text,
                                        ) ??
                                        0.0,
                                    "contactNumber": contactController.text,
                                    "symptomDays":
                                        int.tryParse(
                                          daysController.text,
                                        ) ??
                                        1,
                                    "gender": selectedGender,
                                    "disease": selectedCondition,
                                    "hasPriorMedication": hasMeds,
                                    "priorMedicationName": hasMeds
                                        ? medsNameController.text
                                        : "None",
                                    "patientImageUrl": base64Image, // ✅ BASE64 IMAGE FOR DATABASE
                                    "duration": "${daysController.text} days", // Legacy support
                                  },
                                );
                              },
                            );
                            Navigator.pop(
                              context,
                            );
                          }
                        },
                        child: const Text(
                          "Save Patient",
                        ),
                      ),
                    ],
                  );
                },
          ),
    );
  }

  Future<
    void
  >
  _submitReport() async {
    setState(
      () => isSubmitting = true,
    );

    // Auto-calculate Status Logic (Frontend Validation)
    String status = "Safe";
    double ph =
        double.tryParse(
          phController.text,
        ) ??
        7.0;
    if (ph <
            6.5 ||
        ph >
            8.5 ||
        _victims.isNotEmpty) {
      status = "Unsafe"; // Unsafe if victims exist!
    }

    try {
      final Map<
        String,
        dynamic
      >
      data = {
        "ashaId": _ashaId, // ✅ Use actual logged-in ASHA ID
        "location": "GPS Tagged Village",
        "latitude": currentLat,
        "longitude": currentLong,
        "phLevel": ph,
        "tdsLevel":
            double.tryParse(
              tdsController.text,
            ) ??
            0.0,
        "turbidity":
            double.tryParse(
              turbController.text,
            ) ??
            0.0,
        "status": status,
        "victims": _victims, // ✅ Send victims WITH base64 images to database
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/reports'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(
          data,
        ),
      );

      setState(
        () => isSubmitting = false,
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Report & Patients Saved!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        print('Error Response: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception("Server Error: ${response.statusCode} - ${response.body}");
      }
    } catch (
      e
    ) {
      ApiConfig.logError('/reports', e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              "Error: $e",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(
        () => isSubmitting = false,
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "New Field Report",
        ),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep <
              2) {
            setState(
              () => _currentStep += 1,
            );
          } else {
            _submitReport();
          }
        },
        onStepCancel: () {
          if (_currentStep >
              0)
            setState(
              () => _currentStep -= 1,
            );
        },
        controlsBuilder:
            (
              context,
              details,
            ) {
              return Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF00796B,
                          ),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _currentStep ==
                                        2
                                    ? "SUBMIT REPORT"
                                    : "CONTINUE",
                              ),
                      ),
                    ),
                    if (_currentStep >
                        0) ...[
                      const SizedBox(
                        width: 10,
                      ),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text(
                          "BACK",
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
        steps: [
          // Step 1: Location
          Step(
            title: const Text(
              "Location Data",
            ),
            content: Container(
              padding: const EdgeInsets.all(
                15,
              ),
              decoration: BoxDecoration(
                color: isLocationFound
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isLocationFound
                        ? Icons.check_circle
                        : Icons.gps_not_fixed,
                    color: isLocationFound
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    isLocationFound
                        ? "GPS Locked"
                        : "Fetching Satellites...",
                  ),
                ],
              ),
            ),
            isActive:
                _currentStep >=
                0,
          ),

          // Step 2: Water Data
          Step(
            title: const Text(
              "Water Parameters",
            ),
            content: Column(
              children: [
                CustomTextField(
                  label: "pH Level",
                  icon: Icons.science,
                  controller: phController,
                  isNumber: true,
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomTextField(
                  label: "TDS (ppm)",
                  icon: Icons.water_drop,
                  controller: tdsController,
                  isNumber: true,
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomTextField(
                  label: "Turbidity (NTU)",
                  icon: Icons.opacity,
                  controller: turbController,
                  isNumber: true,
                ),
              ],
            ),
            isActive:
                _currentStep >=
                1,
          ),

          // Step 3: Victim Data (ENHANCED WITH IMAGES)
          Step(
            title: const Text(
              "Health Impact (Victims)",
            ),
            content: Column(
              children: [
                if (_victims.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(
                      10.0,
                    ),
                    child: Text(
                      "No patients added yet.",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ..._victims.map(
                  (
                    v,
                  ) => Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 0,
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        12.0,
                      ),
                      child: Row(
                        children: [
                          // 1. Patient Image (Left Aligned)
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.teal.shade50,
                            backgroundImage:
                                (v['patientImageUrl'] !=
                                        null &&
                                    v['patientImageUrl'].toString().isNotEmpty)
                                ? FileImage(
                                    File(
                                      v['patientImageUrl'],
                                    ),
                                  )
                                : null,
                            child:
                                (v['patientImageUrl'] ==
                                        null ||
                                    v['patientImageUrl'].toString().isEmpty)
                                ? Text(
                                    v['name'][0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.teal.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          // 2. Patient Details (Takes remaining space)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${v['name']} (${v['age']}y)",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "${v['disease']} • ${v['gender']}",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      v['contactNumber']?.toString().isNotEmpty ==
                                              true
                                          ? v['contactNumber']
                                          : "No Contact",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // 3. Delete Button (Right Aligned)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  _victims.remove(
                                    v,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                OutlinedButton.icon(
                  onPressed: _showAddVictimDialog,
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: const Text(
                    "Add Patient Details",
                  ),
                ),
              ],
            ),
            isActive:
                _currentStep >=
                2,
          ),
        ],
      ),
    );
  }
}
