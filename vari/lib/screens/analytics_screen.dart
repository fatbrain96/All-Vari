import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/api_config.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool isLoading = true;
  int totalReports = 0;
  int unsafeReports = 0;
  int totalPatients = 0;
  
  String aiInsight = "Waiting for data to analyze...";
  bool isAiLoading = false;
  final String apiKey = 'AIzaSyAsH15XW6zsyaLMR8b6wj_Qd7qvAst1VBc';

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/reports'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        int unsafeCount = 0;
        int patientsCount = 0;

        for (var report in data) {
          if (report['status'] == 'Unsafe') unsafeCount++;
          if (report['victims'] != null) {
            patientsCount += (report['victims'] as List).length;
          }
        }

        setState(() {
          totalReports = data.length;
          unsafeReports = unsafeCount;
          totalPatients = patientsCount;
          isLoading = false;
        });
        
        // Trigger AI Analysis once data is loaded
        _generateAIInsight();
      }
    } catch (e) {
      ApiConfig.logError('/reports', e);
      setState(() => isLoading = false);
    }
  }

  Future<void> _generateAIInsight() async {
    setState(() => isAiLoading = true);
    
    try {
      print("Connecting to Gemini AI...");
      
      final model = GenerativeModel(
        model: 'gemini-2.5-flash', 
        apiKey: 'AIzaSyAsH15XW6zsyaLMR8b6wj_Qd7qvAst1VBc'
      );
      
      final prompt = "You are an expert public health AI assisting a rural ASHA worker in India. Here is the current data for her village: Total water sources tested: $totalReports. Unsafe/Contaminated sources: $unsafeReports. Total patients currently sick: $totalPatients. Give a concise, 2-sentence medical risk assessment and 1 immediate actionable recommendation. Do not use markdown formatting.";
      
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      print("AI Response Received: ${response.text}");
      
      setState(() {
        aiInsight = response.text ?? "Analysis failed but no error thrown.";
        isAiLoading = false;
      });
    } catch (e) {
      ApiConfig.logError('/gemini-ai', e);
      setState(() {
        aiInsight = "Error Details: $e";
        isAiLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Village Analytics")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Real-Time Overview",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Total Reports",
                          totalReports.toString(),
                          Icons.analytics,
                          Colors.blue
                        )
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          "Unsafe Sources",
                          unsafeReports.toString(),
                          Icons.warning,
                          Colors.red
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildStatCard(
                    "Total Patients Linked",
                    totalPatients.toString(),
                    Icons.personal_injury,
                    Colors.orange,
                    isWide: true
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, color: Colors.purple),
                      SizedBox(width: 10),
                      Text(
                        "AI Risk Intelligence",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.purple.shade200)
                    ),
                    child: isAiLoading
                        ? const Center(
                            child: LinearProgressIndicator(color: Colors.purple)
                          )
                        : Text(
                            aiInsight,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.purple.shade900,
                              fontWeight: FontWeight.w500
                            )
                          ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool isWide = false}) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color
            )
          ),
          Text(
            title,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }
}