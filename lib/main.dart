// main.dart
import 'package:flutter/material.dart';
import 'package:studyapp/social_button.dart';
import 'package:flutter_text_decorator/flutter_text_decorator.dart';

void main() {
  runApp(const StudyApp());
}


class StudyApp extends StatelessWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext  context) {
    return MaterialApp(
      title: 'Study App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 251, 0)),
      ),
      home: const Study(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginField extends StatelessWidget {
  final String hintText;
  final bool isPasswordField;

  const LoginField({super.key, required this.hintText, required this.isPasswordField});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        obscureText: isPasswordField,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color.fromARGB(255, 15, 56, 49),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
class Study extends StatelessWidget {
  const Study({super.key});

  @override
  Widget build(BuildContext  context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 26, 23),

      body: Center(
        child: Container(
          height: 500,
          width: 900,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromARGB(255, 7, 31, 29),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 0, 0, 0),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text(
                  'Bem-vindo ao Study App',
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 217, 1)),
                ),
              ),
              SizedBox(height: 50),
              SocialButton(
              iconName: 'glogo',
              label: 'Login com Google',
              onPressed: () {}),
              SizedBox(height: 20),
              SocialButton(
              iconName: 'flogo',
              label: 'Login com Facebook',
              onPressed: () {}),
              SizedBox(height: 15),
              const Text(
                'ou',
                style: TextStyle(fontSize: 17,),
              ),
              SizedBox(height: 15),
              LoginField(hintText: 'Email', isPasswordField: false),
              SizedBox(height: 20),
              LoginField(hintText: 'Senha', isPasswordField: true,),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}