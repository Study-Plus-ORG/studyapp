// pagina3.dart
import 'package:flutter/material.dart';
import 'package:studyapp/pagina1.dart';

class Pagina3 extends StatelessWidget {
  const Pagina3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Color.fromARGB(221, 2, 22, 19),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(''),
        titleTextStyle: const TextStyle(color: Color.fromARGB(255, 221, 221, 221)),
      ),

      backgroundColor: const Color.fromARGB(255, 2, 22, 19),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  const SizedBox(height: 20),
                  
                  Container(
                    width: 600,
                    height: 120,
                    decoration: BoxDecoration(
                     color: Color.fromARGB(255, 180, 180, 180)
                    ),
                    child: const Center(
                      child: Text(
                        'Disciplinas',
                        style: TextStyle(color: Color.fromARGB(255, 214, 214, 214),
                         fontSize: 40,
                         fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      
                      ),
                    ),
                  ),
                    const SizedBox(height: 50),
                    //subtitulo
                   
                    const SizedBox(height: 20),
                  
                    const SizedBox(height: 50),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Pagina3()),
                      );
                    },
                    child: Container(
                      width: 500,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 168, 168, 168),
                            Color.fromARGB(0, 11, 44, 41),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.book, color: Color.fromARGB(255, 214, 214, 214)),
                            const SizedBox(width: 10),
                            const Text(
                              'Suas Disciplinas',
                              style: TextStyle(
                                color: Color.fromARGB(255, 214, 214, 214),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Pagina1()),
                      );
                    },
                    child: Container(
                      width: 500,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 11, 44, 41),
                            Color.fromARGB(0, 11, 44, 41),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Color.fromARGB(255, 214, 214, 214)),
                            const SizedBox(width: 10),
                            const Text(
                              'Calendario',
                              style: TextStyle(
                                color: Color.fromARGB(255, 214, 214, 214),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Pagina1()),
                      );
                    },
                    child: Container(
                      width: 500,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 11, 44, 41),
                            Color.fromARGB(0, 11, 44, 41),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.school, color: Color.fromARGB(255, 214, 214, 214)),
                            const SizedBox(width: 10),
                            const Text(
                              'Plano de estudos',
                              style: TextStyle(
                                color: Color.fromARGB(255, 214, 214, 214),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Pagina1()),
                      );
                    },
                    child: Container(
                      width: 500,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 11, 44, 41),
                            Color.fromARGB(0, 11, 44, 41),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book, color: Color.fromARGB(255, 214, 214, 214)),
                            const SizedBox(width: 10),
                            const Text(
                              'Estudos',
                              style: TextStyle(
                                color: Color.fromARGB(255, 214, 214, 214),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      
    );
  }
} //STL widget