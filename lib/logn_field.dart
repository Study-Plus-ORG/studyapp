import 'package:flutter/material.dart';

class LoginField extends StatelessWidget {
  const LoginField({
    super.key,
    required this.hintText,
    this.controller,
    this.isPasswordField = false,
    this.icon,
    this.suffixIcon,
    this.onPressed,
    this.keyboardType,
  });

  final String hintText;
  final TextEditingController? controller;
  final bool isPasswordField;
  final IconData? icon;
  final IconData? suffixIcon;
  final VoidCallback? onPressed;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: isPasswordField,
    keyboardType: keyboardType,
    autocorrect: false,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9AB5AF)),
      prefixIcon: icon == null ? null : Icon(icon, color: const Color(0xFF7DE2C3)),
      suffixIcon: suffixIcon == null ? null : IconButton(
        icon: Icon(suffixIcon, color: const Color(0xFFB4CBC6)),
        onPressed: onPressed,
      ),
      filled: true,
      fillColor: const Color(0xFF0C2927),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF7DE2C3), width: 1.5),
      ),
    ),
  );
}
