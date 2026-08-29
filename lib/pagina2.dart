import 'package:flutter/material.dart';
import 'package:studyapp/pagina1.dart';
import 'package:studyapp/pagina3.dart';
import 'package:studyapp/pagina4.dart';
import 'package:studyapp/pagina5.dart';
import 'package:studyapp/study_repository.dart';
import 'package:studyapp/auth_service.dart';

class Pagina2 extends StatefulWidget {
  const Pagina2({super.key});

  static const ink = Color(0xFF061B1A);
  static const surface = Color(0xFF10302E);
  static const mint = Color(0xFF7DE2C3);

  @override
  State<Pagina2> createState() => _Pagina2State();
}

class _Pagina2State extends State<Pagina2> {
  int _subjectCount = 0;
  int _taskCount = 0;
  int _flashcardCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final subjectsFuture = StudyRepository.getSubjects();
      final tasksFuture = StudyRepository.getTasks();
      final flashcardCountFuture = StudyRepository.getFlashcardCount();
      final subjects = await subjectsFuture;
      final tasks = await tasksFuture;
      final flashcardCount = await flashcardCountFuture;
      if (mounted) {
        setState(() {
          _subjectCount = subjects.length;
          _taskCount = tasks.length;
          _flashcardCount = flashcardCount;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pagina2.ink,
      appBar: AppBar(
        backgroundColor: Pagina2.ink,
        elevation: 0,
        title: const Row(children: [
          _Logo(), SizedBox(width: 10),
          Text('Study', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _signOut,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(wide ? 40 : 20, 20, wide ? 40 : 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _WelcomeCard(
                  wide: wide,
                  onStart: () => _go(context, const Pagina3()),
                ),
                const SizedBox(height: 32),
                const Text('Seu dia de estudos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                Wrap(spacing: 14, runSpacing: 14, children: [
                  _StatCard(icon: Icons.menu_book_rounded, value: '$_subjectCount', label: 'disciplinas'),
                  const _StatCard(icon: Icons.timer_outlined, value: '0h', label: 'foco hoje'),
                  _StatCard(icon: Icons.event_available_rounded, value: '$_taskCount', label: 'tarefas'),
                  _StatCard(icon: Icons.style_rounded, value: '$_flashcardCount', label: 'flashcards'),
                ]),
                const SizedBox(height: 32),
                Text('Acesso rápido', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                Wrap(spacing: 16, runSpacing: 16, children: [
                  _ActionCard(
                    width: wide ? 300 : constraints.maxWidth - 40,
                    icon: Icons.auto_stories_rounded,
                    title: 'Disciplinas',
                    description: 'Organize as matérias que você estuda.',
                    color: const Color(0xFF6FE2C1),
                    onTap: () => _go(context, const Pagina3()),
                  ),
                  _ActionCard(
                    width: wide ? 300 : constraints.maxWidth - 40,
                    icon: Icons.calendar_month_rounded,
                    title: 'Calendário',
                    description: 'Planeje provas, tarefas e revisões.',
                    color: const Color(0xFFB7F397),
                    onTap: () => _go(context, const Pagina4()),
                  ),
                  _ActionCard(
                    width: wide ? 300 : constraints.maxWidth - 40,
                    icon: Icons.style_rounded,
                    title: 'Flashcards',
                    description: 'Crie perguntas para revisar com agilidade.',
                    color: const Color(0xFFFFC56B),
                    onTap: () => _go(context, const Pagina5()),
                  ),
                ]),
                const SizedBox(height: 32),
                const _NextStep(),
              ]),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _go(BuildContext context, Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    await _loadDashboard();
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Pagina1()),
          (route) => false,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível sair da conta.')),
        );
      }
    }
  }
}

class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) => Container(
    width: 30, height: 30,
    decoration: BoxDecoration(color: Pagina2.mint, borderRadius: BorderRadius.circular(9)),
    child: const Icon(Icons.school_rounded, color: Pagina2.ink, size: 19),
  );
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.wide, required this.onStart});
  final bool wide;
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(colors: [Color(0xFF164B45), Pagina2.surface]),
    ),
    child: Flex(
      direction: wide ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: wide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: wide ? 4 : 0,
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('Olá! Vamos estudar?', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text('Organize seu tempo, acompanhe suas matérias e avance um pouco todos os dias.', style: TextStyle(color: Color(0xFFC9DFD9), height: 1.5)),
          ]),
        ),
        if (wide) const Spacer(),
        InkWell(
          onTap: onStart,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: EdgeInsets.only(top: wide ? 0 : 22),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFF0C2927), borderRadius: BorderRadius.circular(16)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.local_fire_department_rounded, color: Color(0xFFFFC56B)), SizedBox(width: 8),
              Text('Comece hoje', style: TextStyle(fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value, label;
  @override
  Widget build(BuildContext context) => Container(
    width: 170, padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Pagina2.surface, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: Pagina2.mint), const SizedBox(height: 20),
      Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: Color(0xFFB4CBC6))),
    ]),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.width, required this.icon, required this.title, required this.description, required this.color, required this.onTap});
  final double width;
  final IconData icon;
  final String title, description;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: 266,
    child: Material(
      color: Pagina2.surface, borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: .16), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(description, style: const TextStyle(color: Color(0xFFB4CBC6), height: 1.4)),
            const SizedBox(height: 18),
            const Row(children: [
              Text('Abrir', style: TextStyle(color: Pagina2.mint, fontWeight: FontWeight.w700)),
              Spacer(), Icon(Icons.arrow_forward_rounded, size: 18, color: Pagina2.mint),
            ]),
          ]),
        ),
      ),
    ),
  );
}

class _NextStep extends StatelessWidget {
  const _NextStep();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(border: Border.all(color: const Color(0xFF28514B)), borderRadius: BorderRadius.circular(18)),
    child: const Row(children: [
      Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFFC56B)), SizedBox(width: 14),
      Expanded(child: Text('Dica: cadastre suas disciplinas e depois marque as datas importantes no calendário.')),
    ]),
  );
}
