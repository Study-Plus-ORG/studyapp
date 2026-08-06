// main.dart
import 'package:flutter/material.dart';
import 'package:studyapp/social_button.dart';


void main() {
  runApp(const StudyApp());

}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext  context) {
    return const MaterialApp(
      home: Study(),
      debugShowCheckedModeBanner: false,

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
                  'Login',
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 216, 216, 216)),
                ),
              ),
              const SizedBox(height: 50),
              SocialButton(iconName: 'glogo', label: 'Login com Google', onPressed: () {}),
            ],

          ),
        ),
      ),
    );
  }
}