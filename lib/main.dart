// main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studyapp/pagina1.dart';

void main() {
  runApp(const StudyApp());
}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study App',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.notoSerifDisplayTextTheme(),
        
      ),
      home: const Pagina1(),
    );
  }
}