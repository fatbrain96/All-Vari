import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool isNumber;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.isNumber = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF00796B),
          ),
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
