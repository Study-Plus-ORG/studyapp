// main.dart
import 'package:flutter/material.dart';
import 'package:studyapp/social_button.dart';
import 'package:flutter_text_decorator/flutter_text_decorator.dart';
import 'package:google_fonts/google_fonts.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 6, 12, 68)),
        textTheme: GoogleFonts.notoSerifDisplayTextTheme(),
        
      ),
      home: const Study(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginField extends StatelessWidget {
  final String hintText;
  final bool isPasswordField;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onPressed;

  const LoginField({
    super.key,
    required this.hintText,
    required this.isPasswordField,
    this.prefixIcon,
    this.suffixIcon,
    this.onPressed,
  });

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
          prefixIcon: prefixIcon,
          suffixIcon: onPressed != null && suffixIcon != null
              ? IconButton(
                  icon: suffixIcon!,
                  onPressed: onPressed,
                )
              : suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
class Study extends StatefulWidget {
  const Study({super.key});

  @override
  State<Study> createState() => _StudyState();
}

class _StudyState extends State<Study> {
  bool showPassword = false;

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
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(
                  'Bem-vindo ao Study App',
                  style: GoogleFonts.notoSerifDisplay(
                    fontSize: 50,
                    color: const Color.fromARGB(255, 228, 228, 228),
                  ),
                ),
              ),
              SizedBox(height: 50),
              SocialButton(
              iconName: 'google.svg',
              label: 'Login com Google',
              onPressed: () {}, prefixIcon: null,),
              SizedBox(height: 20),
              SocialButton(
              iconName: 'facebook.svg',
              label: 'Login com Facebook',
              onPressed: () {}, prefixIcon: null,),
              SizedBox(height: 15),
              const Text(
                'ou',
                style: TextStyle(fontSize: 17,),
              ),
              SizedBox(height: 15),
              LoginField(hintText: 'Email', isPasswordField: false, prefixIcon: const Icon(Icons.email, color: Colors.white),),
              SizedBox(height: 20),
              LoginField(
                hintText: 'Senha',
                isPasswordField: !showPassword,
                prefixIcon: const Icon(Icons.lock, color: Colors.white),
                suffixIcon: const Icon(Icons.remove_red_eye, color: Colors.white),
                 onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                 },
              ),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}