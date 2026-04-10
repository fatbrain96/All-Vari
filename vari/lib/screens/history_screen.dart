import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show
        kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'report_details_screen.dart'; // ✅ Import the details screen
import '../services/api_config.dart';

class HistoryScreen
    extends
        StatefulWidget {
  const HistoryScreen({
    super.key,
  });

  @override
  State<
    HistoryScreen
  >
  createState() => _HistoryScreenState();
}

class _HistoryScreenState
    extends
        State<
          HistoryScreen
        > {
  List<
    dynamic
  >
  reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<
    void
  >
  fetchReports() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reports'),
      );
      if (response.statusCode ==
          200) {
        setState(
          () {
            reports = jsonDecode(
              response.body,
            );
            isLoading = false;
          },
        );
      } else {
        throw Exception(
          "Failed to load",
        );
      }
    } catch (
      e
    ) {
      setState(
        () => isLoading = false,
      );
      ApiConfig.logError('/reports', e);
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Report History",
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : reports.isEmpty
          ? const Center(
              child: Text(
                "No reports found.",
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchReports,
              child: ListView.builder(
                itemCount: reports.length,
                padding: const EdgeInsets.all(
                  10,
                ),
                itemBuilder:
                    (
                      context,
                      index,
                    ) {
                      final report = reports[index];
                      final isSafe =
                          report['status'] ==
                          'Safe';

                      // Count victims safely
                      final victims =
                          report['victims']
                              as List?;
                      final victimCount =
                          victims?.length ??
                          0;

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                        ),
                        elevation: 3,
                        color: isSafe
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        child: InkWell(
                          // ✅ Added InkWell for Tap
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                          onTap: () {
                            // Navigate to Details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      _,
                                    ) => ReportDetailsScreen(
                                      report: report,
                                    ),
                              ),
                            );
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(
                              15,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: isSafe
                                  ? Colors.green
                                  : Colors.red,
                              child: Icon(
                                isSafe
                                    ? Icons.check
                                    : Icons.warning_amber_rounded,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              "Report #${report['id']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Lat: ${report['latitude']}, Long: ${report['longitude']}",
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  isSafe
                                      ? "Status: Safe"
                                      : "Status: UNSAFE",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSafe
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                  ),
                                ),
                                if (victimCount >
                                    0)
                                  Container(
                                    margin: const EdgeInsets.only(
                                      top: 8,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        8,
                                      ),
                                      border: Border.all(
                                        color: Colors.orange,
                                      ),
                                    ),
                                    child: Text(
                                      "🏥 $victimCount Patients Linked (Tap to View)",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
              ),
            ),
    );
  }
}
