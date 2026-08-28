import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Pagina4 extends StatefulWidget {
  const Pagina4({super.key});
  @override
  State<Pagina4> createState() => _Pagina4State();
}

class _Pagina4State extends State<Pagina4> {
  final List<Appointment> _events = [];
  DateTime _selected = DateTime.now();

  Future<void> _addEvent() async {
    final title = TextEditingController();
    DateTime date = _selected;
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        backgroundColor: const Color(0xFF10302E),
        title: const Text('Nova atividade'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, autofocus: true, decoration: const InputDecoration(hintText: 'Ex.: Revisar matemática')),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text('${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'),
            onPressed: () async {
              final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100));
              if (picked != null) setDialogState(() => date = picked);
            },
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Adicionar')),
        ],
      )),
    );
    if (created == true && title.text.trim().isNotEmpty) {
      setState(() => _events.add(Appointment(
        subject: title.text.trim(), startTime: DateTime(date.year, date.month, date.day, 9), endTime: DateTime(date.year, date.month, date.day, 10), color: const Color(0xFF7DE2C3),
      )));
    }
    title.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Calendário', style: TextStyle(fontWeight: FontWeight.w800))),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addEvent, backgroundColor: const Color(0xFF7DE2C3), foregroundColor: const Color(0xFF061B1A), icon: const Icon(Icons.add_rounded), label: const Text('Atividade'),
    ),
    body: Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: const Color(0xFF10302E), borderRadius: BorderRadius.circular(24)),
          child: SfCalendar(
            view: CalendarView.month,
            dataSource: _EventSource(_events),
            initialSelectedDate: _selected,
            onSelectionChanged: (details) { if (details.date != null) setState(() => _selected = details.date!); },
            monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.indicator, showTrailingAndLeadingDates: false),
            headerStyle: const CalendarHeaderStyle(textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            viewHeaderStyle: const ViewHeaderStyle(dayTextStyle: TextStyle(color: Color(0xFFB4CBC6)), dateTextStyle: TextStyle(color: Color(0xFF7DE2C3), fontWeight: FontWeight.w700)),
            selectionDecoration: BoxDecoration(border: Border.all(color: const Color(0xFF7DE2C3), width: 2), borderRadius: BorderRadius.circular(8)),
            todayHighlightColor: const Color(0xFFB7F397),
            appointmentTextStyle: const TextStyle(color: Color(0xFF061B1A), fontWeight: FontWeight.w700),
            backgroundColor: const Color(0xFF10302E),
          ),
        ),
      )),
    ),
  );
}

class _EventSource extends CalendarDataSource {
  _EventSource(List<Appointment> source) { appointments = source; }
}
