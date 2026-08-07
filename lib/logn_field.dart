// logn_field.dart
import 'package:flutter/material.dart';

class LoginField extends StatelessWidget {
  final String hintText;
final bool isPasswordField;


  const LoginField({super.key, required this.hintText,
  this.isPasswordField = false});

  @override 
  Widget build(BuildContext context) {
    return ConstrainedBox(constraints: const BoxConstraints(maxWidth: 350),
    child: TextFormField(
      style: const TextStyle(fontSize: 17),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(27),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(200, 200, 200, 200),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(5),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 255, 255, 255),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        hintText: hintText,
      ),
      obscureText: isPasswordField,
    )
    );
  }
}