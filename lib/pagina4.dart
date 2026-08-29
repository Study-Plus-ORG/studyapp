import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:studyapp/study_repository.dart';

class Pagina4 extends StatefulWidget {
  const Pagina4({super.key});
  @override
  State<Pagina4> createState() => _Pagina4State();
}

class _Pagina4State extends State<Pagina4> {
  final List<Appointment> _events = [];
  final CalendarController _calendarController = CalendarController();
  DateTime _selected = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _changeMonth(int offset) {
    if (offset < 0) {
      _calendarController.backward?.call();
    } else {
      _calendarController.forward?.call();
    }
  }

  Future<void> _loadEvents() async {
    try {
      final tasks = await StudyRepository.getTasks();
      if (!mounted) return;
      setState(() {
        _events
          ..clear()
          ..addAll(
            tasks.map((task) {
              final date = DateTime.parse(
                task['data_entrega'] as String,
              ).toLocal();
              return Appointment(
                subject: task['titulo'] as String,
                startTime: date,
                endTime: date.add(const Duration(hours: 1)),
                color: const Color(0xFF7DE2C3),
              );
            }),
          );
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar atividades: $error')),
        );
      }
    }
  }

  Future<void> _showDayActivities(DateTime date) async {
    final activities = _events
        .where((event) => DateUtils.isSameDay(event.startTime, date))
        .toList();
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10302E),
        title: Text('Atividades de $formattedDate'),
        content: SizedBox(
          width: 380,
          child: activities.isEmpty
              ? const Text(
                  'Nenhuma atividade para este dia.',
                  style: TextStyle(color: Color(0xFFB4CBC6)),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: activities.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (_, index) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.event_available_rounded,
                      color: Color(0xFF7DE2C3),
                    ),
                    title: Text(
                      activities[index].subject as String? ?? 'Atividade',
                    ),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addEvent() async {
    final title = TextEditingController();
    DateTime date = _selected;
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF10302E),
          title: const Text('Nova atividade'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Ex.: Revisar matemática',
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setDialogState(() => date = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
    if (created == true && title.text.trim().isNotEmpty) {
      try {
        await StudyRepository.addTask(
          title.text.trim(),
          DateTime(date.year, date.month, date.day, 9),
        );
        await _loadEvents();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar atividade: $error')),
          );
        }
      }
    }
    title.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Calendário',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      actions: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: 'Mês anterior',
        ),
        IconButton(
          onPressed: () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: 'Próximo mês',
        ),
        const SizedBox(width: 8),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addEvent,
      backgroundColor: const Color(0xFF7DE2C3),
      foregroundColor: const Color(0xFF061B1A),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Atividade'),
    ),
    body: Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF10302E),
              borderRadius: BorderRadius.circular(24),
            ),
            child: SfCalendar(
            view: CalendarView.month,
            controller: _calendarController,
              dataSource: _EventSource(_events),
              initialSelectedDate: _selected,
              onSelectionChanged: (details) {
                final selectedDate = details.date;
                if (selectedDate == null ||
                    DateUtils.isSameDay(_selected, selectedDate))
                  return;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _selected = selectedDate);
                });
              },
              onTap: (details) {
                final date = details.date;
                if (date != null) _showDayActivities(date);
              },
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                showTrailingAndLeadingDates: false,
              ),
              headerStyle: const CalendarHeaderStyle(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              viewHeaderStyle: const ViewHeaderStyle(
                dayTextStyle: TextStyle(color: Color(0xFFB4CBC6)),
                dateTextStyle: TextStyle(
                  color: Color(0xFF7DE2C3),
                  fontWeight: FontWeight.w700,
                ),
              ),
              selectionDecoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF7DE2C3), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              todayHighlightColor: const Color(0xFFB7F397),
              appointmentTextStyle: const TextStyle(
                color: Color(0xFF061B1A),
                fontWeight: FontWeight.w700,
              ),
              backgroundColor: const Color(0xFF10302E),
            ),
          ),
        ),
      ),
    ),
  );
}

class _EventSource extends CalendarDataSource {
  _EventSource(List<Appointment> source) {
    appointments = source;
  }
}
