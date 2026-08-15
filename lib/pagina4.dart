// pagina4.dart
import 'package:flutter/material.dart';

class Pagina4 extends StatefulWidget {
  const Pagina4({super.key});

  @override
  State<Pagina4> createState() => _Pagina4State();
}

class _Pagina4State extends State<Pagina4> {
  DateTime _mesExibido = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _diaSelecionado = DateTime.now();
  final Map<DateTime, List<String>> _eventos = {};

  DateTime _apenasData(DateTime d) => DateTime(d.year, d.month, d.day);

  List<String> get _eventosDoDia =>
      _eventos[_apenasData(_diaSelecionado)] ?? [];

  void _mesAnterior() {
    setState(() {
      _mesExibido = DateTime(_mesExibido.year, _mesExibido.month - 1);
    });
  }

  void _proximoMes() {
    setState(() {
      _mesExibido = DateTime(_mesExibido.year, _mesExibido.month + 1);
    });
  }

  void _selecionarDia(DateTime dia) {
    setState(() {
      _diaSelecionado = dia;
    });
  }

  void _abrirDialogoAdicionarEvento() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 11, 44, 41),
          title: const Text(
            'Nova atividade',
            style: TextStyle(color: Color.fromARGB(255, 214, 214, 214)),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Color.fromARGB(255, 214, 214, 214)),
            decoration: const InputDecoration(
              hintText: 'Ex: Prova de Matemática',
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
                final texto = controller.text.trim();
                if (texto.isNotEmpty) {
                  setState(() {
                    final chave = _apenasData(_diaSelecionado);
                    _eventos.putIfAbsent(chave, () => []);
                    _eventos[chave]!.add(texto);
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

  void _removerEvento(int index) {
    setState(() {
      final chave = _apenasData(_diaSelecionado);
      _eventos[chave]!.removeAt(index);
      if (_eventos[chave]!.isEmpty) {
        _eventos.remove(chave);
      }
    });
  }

  List<DateTime?> _diasDoMes() {
    final primeiroDia = DateTime(_mesExibido.year, _mesExibido.month, 1);
    final ultimoDia = DateTime(_mesExibido.year, _mesExibido.month + 1, 0);
    final espacosVazios = primeiroDia.weekday - 1;

    return [
      ...List<DateTime?>.filled(espacosVazios, null),
      ...List.generate(
        ultimoDia.day,
        (i) => DateTime(_mesExibido.year, _mesExibido.month, i + 1),
      ),
    ];
  }

  static const List<String> _nomesMeses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  static const List<String> _diasSemana = [
    'S', 'T', 'Q', 'Q', 'S', 'S', 'D',
  ];

  @override
  Widget build(BuildContext context) {
    final hoje = _apenasData(DateTime.now());
    final dias = _diasDoMes();

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
        onPressed: _abrirDialogoAdicionarEvento,
        child: const Icon(Icons.add, color: Color.fromARGB(255, 11, 44, 41)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                    'Calendário',
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

              Container(
                width: 500,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: Color.fromARGB(255, 214, 214, 214)),
                      onPressed: _mesAnterior,
                    ),
                    Text(
                      '${_nomesMeses[_mesExibido.month - 1]} ${_mesExibido.year}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 214, 214, 214),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right,
                          color: Color.fromARGB(255, 214, 214, 214)),
                      onPressed: _proximoMes,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: 500,
                padding: const EdgeInsets.all(12),
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
                child: Column(
                  children: [
                    Row(
                      children: _diasSemana
                          .map(
                            (d) => Expanded(
                              child: Center(
                                child: Text(
                                  d,
                                  style: const TextStyle(
                                    color: Color.fromARGB(150, 214, 214, 214),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dias.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                      ),
                      itemBuilder: (context, index) {
                        final dia = dias[index];
                        if (dia == null) return const SizedBox.shrink();

                        final diaData = _apenasData(dia);
                        final selecionado = diaData == _apenasData(_diaSelecionado);
                        final ehHoje = diaData == hoje;
                        final temEvento = _eventos.containsKey(diaData);

                        return GestureDetector(
                          onTap: () => _selecionarDia(dia),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: selecionado
                                  ? const Color.fromARGB(255, 168, 168, 168)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: ehHoje && !selecionado
                                  ? Border.all(
                                      color: const Color.fromARGB(255, 168, 168, 168),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  '${dia.day}',
                                  style: TextStyle(
                                    color: selecionado
                                        ? const Color.fromARGB(255, 11, 44, 41)
                                        : const Color.fromARGB(255, 214, 214, 214),
                                    fontSize: 14,
                                    fontWeight: selecionado
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (temEvento)
                                  Positioned(
                                    bottom: 4,
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selecionado
                                            ? const Color.fromARGB(255, 11, 44, 41)
                                            : const Color.fromARGB(255, 214, 214, 214),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'Atividades de ${_diaSelecionado.day}/${_diaSelecionado.month}/${_diaSelecionado.year}',
                style: const TextStyle(
                  color: Color.fromARGB(255, 214, 214, 214),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              if (_eventosDoDia.isEmpty)
                Container(
                  width: 500,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(199, 146, 146, 146),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          'Nada por enquanto...',
                          style: TextStyle(
                            color: Color.fromARGB(255, 214, 214, 214),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: List.generate(_eventosDoDia.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: [
                              const Icon(Icons.event,
                                  color: Color.fromARGB(255, 214, 214, 214)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _eventosDoDia[index],
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 214, 214, 214),
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color.fromARGB(255, 214, 214, 214),
                                  size: 20,
                                ),
                                onPressed: () => _removerEvento(index),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
} //STL widget