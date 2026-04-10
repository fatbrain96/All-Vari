import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_config.dart';

class MobileMapScreen extends StatefulWidget {
  const MobileMapScreen({super.key});

  @override
  State<MobileMapScreen> createState() => _MobileMapScreenState();
}

class _MobileMapScreenState extends State<MobileMapScreen> {
  bool isLoading = true;
  List<dynamic> reports = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/reports'));
      if (response.statusCode == 200) {
        setState(() {
          reports = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      ApiConfig.logError('/reports', e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng centerLocation = const LatLng(20.5937, 78.9629);
    if (reports.isNotEmpty && reports[0]['latitude'] != null) {
      centerLocation = LatLng(reports[0]['latitude'], reports[0]['longitude']);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("District Heatmap")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: centerLocation,
                initialZoom: 5.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.vari.app',
                ),
                MarkerLayer(
                  markers: reports
                      .where((r) => r['latitude'] != null && r['longitude'] != null)
                      .map((r) {
                    final isSafe = r['status'] == 'Safe';
                    final victimsCount = (r['victims'] as List?)?.length ?? 0;
                    final ph = r['phLevel'] ?? "N/A";
                    
                    // Smart Color & Icon Logic
                    Color markerColor;
                    IconData markerIcon;
                    if (isSafe) {
                      markerColor = Colors.green;
                      markerIcon = Icons.health_and_safety; // Green Shield
                    } else if (victimsCount == 0) {
                      markerColor = Colors.amber;
                      markerIcon = Icons.warning_rounded;
                    } else {
                      markerColor = Colors.red;
                      markerIcon = Icons.coronavirus;
                    }
                    
                    return Marker(
                      point: LatLng(r['latitude'], r['longitude']),
                      width: 70,
                      height: 70,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Case #${r['id']} | pH: $ph | Status: ${r['status']} | Patients: $victimsCount")
                            ),
                          );
                        },
                        child: _buildAnimatedMarker(markerColor, markerIcon, isSafe),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  Widget _buildAnimatedMarker(Color color, IconData icon, bool isSafe) {
    // If it's safe, don't pulsate, just show a calm static icon
    if (isSafe) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.2),
        ),
        child: Icon(icon, color: color, size: 35),
      );
    }

    // If Unsafe (Yellow or Red), make it pulsate and glow!
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.2),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      onEnd: () => setState(() {}),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 1.0 - (scale - 0.9) * 3.3),
                ),
              ),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.8),
                      blurRadius: 15.0,
                      spreadRadius: 5.0
                    )
                  ],
                ),
              ),
              Icon(icon, color: Colors.white, size: 22),
            ],
          ),
        );
      },
    );
  }
}