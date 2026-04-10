import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _ashaId = "Loading...";
  String _name = "Loading...";
  String _village = "Loading...";
  String _phone = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ashaId = prefs.getString('ashaId') ?? 'Unknown ID';
      _name = prefs.getString('workerName') ?? 'Unknown Worker';
      _village = prefs.getString('assignedVillage') ?? 'Unassigned';
      _phone = prefs.getString('workerPhone') ?? 'Not Available';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear session
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ASHA Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF00796B),
              child: Text(
                _name.isNotEmpty && _name != "Loading..." ? _name[0].toUpperCase() : "?",
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            Text(
              "Govt. Health Worker",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)
            ),
            const SizedBox(height: 40),
            _buildProfileItem(Icons.badge, "ASHA ID", _ashaId),
            const SizedBox(height: 15),
            _buildProfileItem(Icons.location_on, "Assigned Village", _village),
            const SizedBox(height: 15),
            _buildProfileItem(Icons.phone, "Mobile Number", _phone),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red)
                ),
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text("Secure Logout"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10
          )
        ]
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00796B)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12)
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ],
          )
        ],
      ),
    );
  }
}