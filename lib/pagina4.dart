import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:studyapp/study_repository.dart';
import 'package:studyapp/deadline_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class Pagina4 extends StatefulWidget {
  const Pagina4({super.key});
  @override
  State<Pagina4> createState() => _Pagina4State();
}

class _Pagina4State extends State<Pagina4> {
  final List<_CalendarEvent> _events = [];
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
              return _CalendarEvent(
                id: (task['id_tarefa'] as num).toInt(),
                title: task['titulo'] as String,
                startTime: date,
                completed: task['concluida'] == true,
              );
            }),
          );
      });
      for (final event in _events) {
        if (event.completed) {
          await DeadlineNotifications.cancel(event.id);
        } else {
          await DeadlineNotifications.schedule(
            taskId: event.id,
            title: event.title,
            deadline: event.startTime,
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar atividades: $error')),
        );
      }
    }
  }

  Future<bool> _toggleEventCompletion(_CalendarEvent event) async {
    try {
      await StudyRepository.updateTaskCompletion(event.id, !event.completed);
      await _loadEvents();
      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar atividade: $error')),
        );
      }
      return false;
    }
  }

  Future<bool> _removeEvent(_CalendarEvent event) async {
    try {
      await StudyRepository.deleteTask(event.id);
      await DeadlineNotifications.cancel(event.id);
      await _loadEvents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atividade removida.')),
        );
      }
      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover atividade: $error')),
        );
      }
      return false;
    }
  }

  Future<void> _shareEvent(_CalendarEvent event) async {
    final email = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFF10302E),
          title: const Text('Compartilhar atividade'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text(
                'O colega precisa ter uma conta com este e-mail. A atividade será adicionada ao calendário dele.',
                style: TextStyle(color: Color(0xFFB4CBC6)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail do colega'),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Enviar')),
          ],
        ),
    );
    if (accepted != true || email.text.trim().isEmpty) {
      email.dispose();
      return;
    }
    final recipient = email.text.trim();
    try {
      await StudyRepository.shareTask(taskId: event.id, recipientEmail: recipient);
      final date = '${event.startTime.day.toString().padLeft(2, '0')}/${event.startTime.month.toString().padLeft(2, '0')}/${event.startTime.year}';
      final message = 'Compartilhei a atividade "${event.title}" para $date no Study.';
      final uri = Uri(
        scheme: 'mailto',
        path: recipient,
        queryParameters: {
          'subject': 'Atividade compartilhada no Study',
          'body': message,
        },
      );
      final sent = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sent
                  ? 'Atividade compartilhada e mensagem de e-mail aberta.'
                  : 'Atividade compartilhada, mas não foi possível abrir o e-mail.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível compartilhar: $error')));
      }
    } finally {
      email.dispose();
    }
  }

  Future<void> _showDayActivities(DateTime date) async {
    final activities = _events
        .where((event) => DateUtils.isSameDay(event.startTime, date))
        .toList();
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10302E),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atividades de $formattedDate',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (activities.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Nenhuma atividade para este dia.',
                      style: TextStyle(color: Color(0xFFB4CBC6)),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: activities.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (_, index) {
                        final activity = activities[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Checkbox(
                            value: activity.completed,
                            activeColor: const Color(0xFF7DE2C3),
                            onChanged: (_) async {
                              final updated = await _toggleEventCompletion(activity);
                              if (updated && sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                            },
                          ),
                          title: Text(
                            activity.title,
                            style: TextStyle(
                              decoration: activity.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: activity.completed
                                  ? const Color(0xFFB4CBC6)
                                  : Colors.white,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () => _showActivityMenu(sheetContext, activity),
                            icon: const Icon(Icons.more_vert_rounded),
                            tooltip: 'Opções da atividade',
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showActivityMenu(BuildContext dialogContext, _CalendarEvent activity) async {
    final action = await showModalBottomSheet<_ActivityAction>(
      context: dialogContext,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.person_add_alt_1_outlined), title: const Text('Compartilhar'), onTap: () => Navigator.pop(context, _ActivityAction.share)),
          ListTile(leading: const Icon(Icons.delete_outline_rounded), title: const Text('Remover'), onTap: () => Navigator.pop(context, _ActivityAction.remove)),
        ]),
      ),
    );
    if (action == _ActivityAction.share) {
      await _shareEvent(activity);
    } else if (action == _ActivityAction.remove) {
      final removed = await _removeEvent(activity);
      if (removed && dialogContext.mounted) Navigator.pop(dialogContext);
    }
  }

  Future<void> _addEvent() async {
    final title = TextEditingController();
    DateTime date = _selected;
    var repeatPeriod = _RepeatPeriod.none;
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
              const SizedBox(height: 10),
              DropdownButtonFormField<_RepeatPeriod>(
                initialValue: repeatPeriod,
                decoration: const InputDecoration(labelText: 'Gerar uma nova atividade em'),
                items: const [
                  DropdownMenuItem(value: _RepeatPeriod.none, child: Text('Não repetir')),
                  DropdownMenuItem(value: _RepeatPeriod.week, child: Text('Daqui a uma semana')),
                  DropdownMenuItem(value: _RepeatPeriod.month, child: Text('No próximo mês')),
                ],
                onChanged: (value) => setDialogState(
                  () => repeatPeriod = value ?? _RepeatPeriod.none,
                ),
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
        final task = await StudyRepository.addTask(
          title.text.trim(),
          DateTime(date.year, date.month, date.day, 9),
        );
        if (repeatPeriod != _RepeatPeriod.none) {
          await StudyRepository.addTask(
            title.text.trim(),
            _nextRepeatDate(date, repeatPeriod),
          );
        }
        await DeadlineNotifications.schedule(
          taskId: (task['id_tarefa'] as num).toInt(),
          title: title.text.trim(),
          deadline: DateTime(date.year, date.month, date.day, 9),
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
    body: LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: EdgeInsets.fromLTRB(
          constraints.maxWidth < 420 ? 8 : 20,
          10,
          constraints.maxWidth < 420 ? 8 : 20,
          20,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFF10302E),
                borderRadius: BorderRadius.circular(constraints.maxWidth < 420 ? 16 : 24),
              ),
              child: SfCalendar(
            view: CalendarView.month,
            controller: _calendarController,
              dataSource: _EventSource(_events),
              initialSelectedDate: _selected,
              onSelectionChanged: (details) {
                final selectedDate = details.date;
                if (selectedDate == null ||
                    DateUtils.isSameDay(_selected, selectedDate)) {
                  return;
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _selected = selectedDate);
                });
              },
              onTap: (details) {
                // Ao tocar no cartão da atividade, algumas versões do
                // calendário não preenchem `details.date`. Nesse caso, a
                // própria atividade informa o dia que deve ser aberto.
                _CalendarEvent? tappedEvent;
                for (final appointment in details.appointments ?? const []) {
                  if (appointment is _CalendarEvent) {
                    tappedEvent = appointment;
                    break;
                  }
                }
                final date = tappedEvent?.startTime ?? details.date;
                if (date != null) {
                  _showDayActivities(date);
                }
              },
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                showTrailingAndLeadingDates: false,
              ),
              appointmentBuilder: (context, details) {
                final event = details.appointments.first as _CalendarEvent;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: event.completed
                        ? const Color(0xFF7DE2C3).withValues(alpha: .38)
                        : const Color(0xFF7DE2C3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF061B1A),
                      fontWeight: FontWeight.w700,
                      decoration: event.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                );
              },
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
    ),
  );
}

enum _ActivityAction { share, remove }

enum _RepeatPeriod { none, week, month }

DateTime _nextRepeatDate(DateTime date, _RepeatPeriod period) {
  final scheduled = DateTime(date.year, date.month, date.day, 9);
  return switch (period) {
    _RepeatPeriod.week => scheduled.add(const Duration(days: 7)),
    _RepeatPeriod.month => DateTime(
        scheduled.year,
        scheduled.month + 1,
        scheduled.day,
        scheduled.hour,
      ),
    _RepeatPeriod.none => scheduled,
  };
}

class _EventSource extends CalendarDataSource {
  _EventSource(List<_CalendarEvent> source) {
    appointments = source;
  }

  _CalendarEvent _event(int index) => appointments![index] as _CalendarEvent;

  @override
  DateTime getStartTime(int index) => _event(index).startTime;

  @override
  DateTime getEndTime(int index) =>
      _event(index).startTime.add(const Duration(hours: 1));

  @override
  String getSubject(int index) => _event(index).title;

  @override
  Color getColor(int index) => const Color(0xFF7DE2C3);
}

class _CalendarEvent {
  const _CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.completed,
  });

  final int id;
  final String title;
  final DateTime startTime;
  final bool completed;
}
