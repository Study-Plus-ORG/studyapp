// pagina3.dart
import 'package:flutter/material.dart';
import 'package:studyapp/pagina4.dart';

class Pagina3 extends StatefulWidget {
  const Pagina3({super.key});

  @override
  State<Pagina3> createState() => _Pagina3State();
}

class _Pagina3State extends State<Pagina3> {

  final List<String> _disciplinas = [
    'Matemática',
    'História',
    'Física',
  ];

  void botaoadd() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 11, 44, 41),
          title: const Text(
            'Nova disciplina',
            style: TextStyle(color: Color.fromARGB(255, 214, 214, 214)),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Color.fromARGB(255, 214, 214, 214)),
            decoration: const InputDecoration(
              hintText: 'Ex: Química',
              hintStyle: TextStyle(color: Color.fromARGB(150, 214, 214, 214)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 168, 168, 168)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 214, 214, 214)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color.fromARGB(255, 168, 168, 168)),
              ),
            ),
            TextButton(
              onPressed: () {
                final nome = controller.text.trim();
                if (nome.isNotEmpty) {
                  setState(() {
                    _disciplinas.add(nome);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Adicionar',
                style: TextStyle(color: Color.fromARGB(255, 214, 214, 214)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _removerDisciplina(int index) {
    setState(() {
      _disciplinas.removeAt(index);
    });
  }

  void _editarDisciplina(int index) {
    final TextEditingController controller =
        TextEditingController(text: _disciplinas[index]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 11, 44, 41),
          title: const Text(
            'Editar disciplina',
            style: TextStyle(color: Color.fromARGB(255, 214, 214, 214)),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Color.fromARGB(255, 214, 214, 214)),
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 168, 168, 168)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 214, 214, 214)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color.fromARGB(255, 168, 168, 168)),
              ),
            ),
            TextButton(
              onPressed: () {
                final nome = controller.text.trim();
                if (nome.isNotEmpty) {
                  setState(() {
                    _disciplinas[index] = nome;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Salvar',
                style: TextStyle(color: Color.fromARGB(255, 214, 214, 214)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(221, 2, 22, 19),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(''),
        titleTextStyle: const TextStyle(color: Color.fromARGB(255, 221, 221, 221)),
      ),
      backgroundColor: const Color.fromARGB(255, 2, 22, 19),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 168, 168, 168),
        onPressed: botaoadd,
        child: const Icon(Icons.add, color: Color.fromARGB(255, 11, 44, 41)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 600,
              height: 120,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 180, 180, 180),
              ),
              child: const Center(
                child: Text(
                  'Suas Disciplinas',
                  style: TextStyle(
                    color: Color.fromARGB(255, 214, 214, 214),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),

            const SizedBox(height: 50),
            Expanded(
              child: _disciplinas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma disciplina cadastrada.\nToque no + para adicionar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(150, 214, 214, 214),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _disciplinas.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        return Container(
                          width: 500,
                          height: 50,
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
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.book,
                                  color: Color.fromARGB(255, 214, 214, 214),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _disciplinas[index],
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 214, 214, 214),
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color.fromARGB(255, 214, 214, 214),
                                    size: 20,
                                  ),
                                  onPressed: () => _editarDisciplina(index),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Color.fromARGB(255, 214, 214, 214),
                                    size: 20,
                                  ),
                                  onPressed: () => _removerDisciplina(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}