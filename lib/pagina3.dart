import 'package:flutter/material.dart';
import 'package:studyapp/study_repository.dart';

class Pagina3 extends StatefulWidget {
  const Pagina3({super.key});
  @override
  State<Pagina3> createState() => _Pagina3State();
}

class _Pagina3State extends State<Pagina3> {
  List<Map<String, dynamic>> _subjects = [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await StudyRepository.getSubjects();
      if (mounted)
        setState(() {
          _subjects = data;
          _loading = false;
        });
    } catch (error) {
      if (mounted) {
        setState(() => _loading = false);
        _error(error);
      }
    }
  }

  Future<void> _edit({Map<String, dynamic>? subject}) async {
    final controller = TextEditingController(
      text: subject?['nome'] as String? ?? '',
    );
    final planningController = TextEditingController(
      text: subject?['planejamento'] as String? ?? '',
    );
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10302E),
          title: Text(subject == null ? 'Nova disciplina' : 'Editar disciplina'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: _subjects.isEmpty ? 'Ex.: Química' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Avançar'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) {
      controller.dispose();
      planningController.dispose();
      return;
    }
    final planning = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10302E),
        title: Text('Planejar $name'),
        content: TextField(
          controller: planningController,
          autofocus: true,
          maxLength: 250,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Planejar',
            hintText: _subjects.isEmpty ? 'Ex.: Modelos atômicos' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, planningController.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    planningController.dispose();
    if (planning == null) return;
    try {
      if (subject == null) {
        await StudyRepository.addSubject(name, planning);
      } else {
        await StudyRepository.updateSubject(
          (subject['id_disciplina'] as num).toInt(),
          name,
          planning,
        );
      }
      await _load();
    } catch (error) {
      _error(error);
    }
  }

  Future<void> _delete(Map<String, dynamic> subject) async {
    try {
      await StudyRepository.deleteSubject(
        (subject['id_disciplina'] as num).toInt(),
      );
      await _load();
    } catch (error) {
      _error(error);
    }
  }

  void _error(Object e) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('Erro ao salvar disciplina: $e')));
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Disciplinas',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _edit(),
      backgroundColor: const Color(0xFF7DE2C3),
      foregroundColor: const Color(0xFF061B1A),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Disciplina'),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Suas matérias',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mantenha tudo organizado para montar uma rotina eficiente.',
                    style: TextStyle(color: Color(0xFFB4CBC6)),
                  ),
                  const SizedBox(height: 26),
                  if (_subjects.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Nenhuma disciplina cadastrada ainda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFB4CBC6)),
                      ),
                    ),
                  ..._subjects.map(
                    (subject) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF10302E),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF7DE2C3,
                              ).withValues(alpha: .14),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              color: Color(0xFF7DE2C3),
                            ),
                          ),
                          title: Text(
                            subject['nome'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            (subject['planejamento'] as String? ?? '').isEmpty
                                ? 'Sem planejamento'
                                : subject['planejamento'] as String,
                            style: const TextStyle(color: Color(0xFFB4CBC6)),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) => action == 'edit'
                                ? _edit(subject: subject)
                                : _delete(subject),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Remover'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}
