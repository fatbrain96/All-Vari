import 'package:flutter/material.dart';
import 'dart:io';

class ReportDetailsScreen
    extends
        StatelessWidget {
  final Map<
    String,
    dynamic
  >
  report;

  const ReportDetailsScreen({
    super.key,
    required this.report,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final isSafe =
        report['status'] ==
        'Safe';
    final victims =
        report['victims']
            as List;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Case #${report['id']}",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                20,
              ),
              decoration: BoxDecoration(
                color: isSafe
                    ? Colors.green
                    : Colors.red,
                borderRadius: BorderRadius.circular(
                  15,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isSafe
                        ? Icons.check_circle
                        : Icons.warning,
                    color: Colors.white,
                    size: 50,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    isSafe
                        ? "WATER IS SAFE"
                        : "CONTAMINATION ALERT",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Recorded on: ${report['createdAt']?.toString().split('T')[0] ?? 'Unknown Date'}",
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),

            // 2. Water Data
            const Text(
              "🧪 Water Analysis",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(
                  15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      "pH",
                      report['phLevel'].toString(),
                    ),
                    _buildStat(
                      "TDS",
                      "${report['tdsLevel']} ppm",
                    ),
                    _buildStat(
                      "Turbidity",
                      "${report['turbidity']} NTU",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),

            // 3. Patient List
            const Text(
              "Affected Patients",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (victims.isEmpty)
              const Text(
                "No patients reported linked to this source.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              )
            else
              ...victims.map(
                (
                  v,
                ) => Card(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: ExpansionTile(
                    // Expandable tile for patient details
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Text(
                        v['name'][0],
                        style: TextStyle(
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    title: Text(
                      v['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${v['age']} Y • ${v['gender']} • ${v['disease']}",
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(
                          15.0,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            // Patient Image Display
                            if (v['patientImageUrl'] !=
                                    null &&
                                v['patientImageUrl'].toString().isNotEmpty)
                              _buildPatientImageWidget(v['patientImageUrl'])
                            else
                              const Text(
                                "No Image Available",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "📞 ${v['contactNumber'] ?? 'N/A'}",
                                ),
                                Text(
                                  "⚖️ ${v['weight'] ?? '-'} kg",
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "📅 Sick for: ${v['symptomDays'] ?? '?'} days",
                                ),
                                Text(
                                  "💊 Meds: ${v['hasPriorMedication'] == true ? v['priorMedicationName'] : 'None'}",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    String label,
    String value,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientImageWidget(String imagePath) {
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        );
      } else {
        return Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade200,
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported),
              SizedBox(height: 8),
              Text('Image file not found', style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      }
    } catch (e) {
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Icon(Icons.error),
      );
    }
  }
}
