import 'package:flutter/material.dart';
import 'package:studyapp/study_repository.dart';
import 'package:studyapp/study_session_store.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});
  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  int _subjects = 0, _completedSubjects = 0, _tasks = 0, _completedTasks = 0;

  @override
  void initState() { super.initState(); _loadProgress(); }

  Future<void> _loadProgress() async {
    try {
      final results = await Future.wait([StudyRepository.getSubjects(), StudyRepository.getTasks()]);
      final subjects = results[0]; final tasks = results[1];
      if (mounted) setState(() {
        _subjects = subjects.length; _completedSubjects = subjects.where((item) => item['concluida'] == true).length;
        _tasks = tasks.length; _completedTasks = tasks.where((item) => item['concluida'] == true).length;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Relatórios de estudo', style: TextStyle(fontWeight: FontWeight.w800))),
    body: ValueListenableBuilder<List<StudySession>>(
      valueListenable: StudySessionStore.sessions,
      builder: (context, sessions, _) {
        final now = DateTime.now();
        final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
        final weekFocus = days.fold(Duration.zero, (total, day) => total + StudySessionStore.focusOn(day, sessions));
        final sessionCount = days.fold(0, (total, day) => total + StudySessionStore.completedOn(day, sessions));
        return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Seu progresso', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Acompanhe as sessões concluídas no Pomodoro e o andamento da sua rotina.', style: TextStyle(color: Color(0xFFB4CBC6))),
          const SizedBox(height: 24),
          Wrap(spacing: 14, runSpacing: 14, children: [
            _Metric(icon: Icons.timer_outlined, value: _formatDuration(weekFocus), label: 'foco nesta semana', color: const Color(0xFF7DE2C3)),
            _Metric(icon: Icons.local_fire_department_rounded, value: '${_streak(sessions, now)} dias', label: 'sequência atual', color: const Color(0xFFFFC56B)),
            _Metric(icon: Icons.check_circle_outline_rounded, value: '$sessionCount', label: 'Pomodoros concluídos', color: const Color(0xFFB7F397)),
          ]),
          const SizedBox(height: 28), _FocusChart(days: days, sessions: sessions), const SizedBox(height: 20),
          _ProgressCard(title: 'Disciplinas concluídas', completed: _completedSubjects, total: _subjects, icon: Icons.menu_book_rounded), const SizedBox(height: 12),
          _ProgressCard(title: 'Atividades concluídas', completed: _completedTasks, total: _tasks, icon: Icons.task_alt_rounded), const SizedBox(height: 28),
          Text('Sessões recentes', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 12),
          if (sessions.isEmpty) const _EmptySessions() else ...sessions.reversed.take(5).map((s) => _SessionTile(session: s)),
        ])));
      },
    ),
  );

  int _streak(List<StudySession> sessions, DateTime now) {
    var total = 0; var day = DateTime(now.year, now.month, now.day);
    while (StudySessionStore.completedOn(day, sessions) > 0) { total++; day = day.subtract(const Duration(days: 1)); }
    return total;
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label, required this.color});
  final IconData icon; final String value, label; final Color color;
  @override Widget build(BuildContext context) => Container(width: 190, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF10302E), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const SizedBox(height: 20), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)), Text(label, style: const TextStyle(color: Color(0xFFB4CBC6)))]));
}

class _FocusChart extends StatelessWidget {
  const _FocusChart({required this.days, required this.sessions}); final List<DateTime> days; final List<StudySession> sessions;
  @override Widget build(BuildContext context) {
    final values = days.map((day) => StudySessionStore.focusOn(day, sessions).inMinutes).toList(); final max = values.fold(25, (a, b) => a > b ? a : b); const names = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF10302E), borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Foco nos últimos 7 dias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Minutos de estudo concluídos', style: TextStyle(color: Color(0xFFB4CBC6))), const SizedBox(height: 24), SizedBox(height: 160, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(days.length, (i) { final h = values[i] == 0 ? 5.0 : 110.0 * values[i] / max; return Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [Text(values[i] == 0 ? '' : '${values[i]}m', style: const TextStyle(fontSize: 11, color: Color(0xFFC9DFD9))), const SizedBox(height: 6), AnimatedContainer(duration: const Duration(milliseconds: 250), height: h, margin: const EdgeInsets.symmetric(horizontal: 5), decoration: BoxDecoration(color: const Color(0xFF7DE2C3), borderRadius: BorderRadius.circular(8))), const SizedBox(height: 8), Text(names[(days[i].weekday - 1) % 7], style: const TextStyle(fontSize: 11, color: Color(0xFFB4CBC6)))])); }))) ]));
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.title, required this.completed, required this.total, required this.icon}); final String title; final int completed, total; final IconData icon;
  @override Widget build(BuildContext context) { final progress = total == 0 ? 0.0 : completed / total; return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF10302E), borderRadius: BorderRadius.circular(18)), child: Row(children: [Icon(icon, color: const Color(0xFFB7F397)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 8), LinearProgressIndicator(value: progress, minHeight: 7, borderRadius: BorderRadius.circular(9), backgroundColor: const Color(0xFF28514B), color: const Color(0xFFB7F397))])), const SizedBox(width: 14), Text('$completed/$total', style: const TextStyle(fontWeight: FontWeight.w800))])); }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session}); final StudySession session;
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: const Color(0xFF10302E), borderRadius: BorderRadius.circular(16)), child: ListTile(leading: const Icon(Icons.check_circle_rounded, color: Color(0xFF7DE2C3)), title: Text('Sessão de ${_formatDuration(session.duration)}'), subtitle: Text('${session.finishedAt.day.toString().padLeft(2, '0')}/${session.finishedAt.month.toString().padLeft(2, '0')} às ${session.finishedAt.hour.toString().padLeft(2, '0')}:${session.finishedAt.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0xFFB4CBC6)))));
}
class _EmptySessions extends StatelessWidget { const _EmptySessions(); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF10302E), borderRadius: BorderRadius.circular(18)), child: const Text('Conclua um Pomodoro para ver seu histórico aqui.', style: TextStyle(color: Color(0xFFB4CBC6)))); }
String _formatDuration(Duration duration) { final h = duration.inHours; final m = duration.inMinutes.remainder(60); return h == 0 ? '${m}min' : '${h}h${m == 0 ? '' : ' ${m}min'}'; }
