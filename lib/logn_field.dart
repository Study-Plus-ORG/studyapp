// logn_field.dart
import 'package:flutter/material.dart';

class LoginField extends StatelessWidget {
  final String hintText;
  final bool isPasswordField;
  final Icon? icon;
  final Icon? suffixIcon;
  final VoidCallback? onPressed;

  const LoginField({
    super.key,
    required this.hintText,
    this.isPasswordField = false,
    this.icon,
    this.suffixIcon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350),
      child: TextFormField(
        style: const TextStyle(fontSize: 17, color: Colors.white),
        obscureText: isPasswordField,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(20),
          prefixIcon: icon,
          suffixIcon: onPressed != null && suffixIcon != null
              ? IconButton(
                  icon: suffixIcon!,
                  onPressed: onPressed,
                )
              : suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(200, 200, 200, 200),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}