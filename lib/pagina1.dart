// pagina1.dart
import 'package:flutter/material.dart';
import 'package:studyapp/social_button.dart';
import 'package:studyapp/logn_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studyapp/pagina2.dart';

class Pagina1 extends StatefulWidget {
  const Pagina1({super.key});

  @override
  State<Pagina1> createState() => _Pagina1State();
}

class _Pagina1State extends State<Pagina1> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 22, 19),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 150),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Bem-vindo',
                    style: GoogleFonts.notoSerifDisplay(
                      fontSize: 50,

                      fontWeight: FontWeight.bold,

                      color: const Color.fromARGB(255, 228, 228, 228),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  SocialButton(
                    iconName: 'glogo.svg',
                    label: 'Login com Google',
                    onPressed: () {},
                    prefixIcon: null,
                  ),
                  const SizedBox(height: 20),
                  SocialButton(
                    iconName: 'facebook.svg',
                    label: 'Login com Facebook',
                    onPressed: () {},
                    prefixIcon: null,
                  ),
                  const SizedBox(height: 15),
                  const Text('ou', style: TextStyle(fontSize: 17)),
                  const SizedBox(height: 15),
                  LoginField(
                    hintText: 'Email',
                    isPasswordField: false,
                    icon: const Icon(Icons.email, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  LoginField(
                    hintText: 'Senha',
                    isPasswordField: !showPassword,
                    icon: const Icon(Icons.lock, color: Colors.white),
                    suffixIcon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Pagina2()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 26, 23),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Entrar',
                      style: GoogleFonts.notoSerifDisplay(
                        fontSize: 20,
                        color: const Color.fromARGB(255, 228, 228, 228),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}