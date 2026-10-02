import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studyapp/study_session_store.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  static const _focus = Duration(minutes: 25);
  static const _shortPause = Duration(minutes: 5);
  static const _longPause = Duration(minutes: 15);
  Timer? _timer;
  Duration _remaining = _focus;
  _Mode _mode = _Mode.focus;
  bool _running = false;
  int _cycles = 0;

  Duration get _duration => switch (_mode) { _Mode.focus => _focus, _Mode.shortPause => _shortPause, _Mode.longPause => _longPause };
  String get _label => switch (_mode) { _Mode.focus => 'Hora de focar', _Mode.shortPause => 'Pausa curta', _Mode.longPause => 'Pausa longa' };
  Color get _color => _mode == _Mode.focus ? const Color(0xFF7DE2C3) : const Color(0xFFB7F397);

  void _toggle() {
    if (_running) { _timer?.cancel(); setState(() => _running = false); return; }
    setState(() => _running = true);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 1) { _finishPeriod(); } else { setState(() => _remaining -= const Duration(seconds: 1)); }
    });
  }

  void _finishPeriod() {
    _timer?.cancel();
    final wasFocus = _mode == _Mode.focus;
    if (wasFocus) { StudySessionStore.addFocusSession(_focus); _cycles++; }
    final next = wasFocus ? (_cycles % 4 == 0 ? _Mode.longPause : _Mode.shortPause) : _Mode.focus;
    setState(() { _mode = next; _remaining = _duration; _running = true; });
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(wasFocus ? 'Pomodoro concluído! A pausa começou automaticamente.' : 'Pausa finalizada. O foco recomeçou automaticamente.')));
  }

  void _reset() { _timer?.cancel(); setState(() { _remaining = _duration; _running = false; }); }
  void _selectMode(_Mode mode) { _timer?.cancel(); setState(() { _mode = mode; _remaining = _duration; _running = false; }); }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    final progress = 1 - _remaining.inSeconds / _duration.inSeconds;
    return Scaffold(appBar: AppBar(title: const Text('Pomodoro', style: TextStyle(fontWeight: FontWeight.w800))), body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: Column(children: [
      SegmentedButton<_Mode>(segments: const [ButtonSegment(value: _Mode.focus, label: Text('Foco')), ButtonSegment(value: _Mode.shortPause, label: Text('Pausa curta')), ButtonSegment(value: _Mode.longPause, label: Text('Pausa longa'))], selected: {_mode}, onSelectionChanged: _running ? null : (value) => _selectMode(value.first)),
      const SizedBox(height: 36),
      SizedBox(width: 286, height: 286, child: Stack(alignment: Alignment.center, children: [SizedBox(width: 286, height: 286, child: CircularProgressIndicator(value: progress, strokeWidth: 12, backgroundColor: const Color(0xFF28514B), color: _color, strokeCap: StrokeCap.round)), Column(mainAxisSize: MainAxisSize.min, children: [Icon(_mode == _Mode.focus ? Icons.psychology_rounded : Icons.coffee_rounded, color: _color, size: 32), const SizedBox(height: 12), Text(_label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text('$minutes:$seconds', style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w800, letterSpacing: 1))])])),
      const SizedBox(height: 34), Row(mainAxisAlignment: MainAxisAlignment.center, children: [OutlinedButton.icon(onPressed: _reset, icon: const Icon(Icons.restart_alt_rounded), label: const Text('Reiniciar')), const SizedBox(width: 14), FilledButton.icon(onPressed: _toggle, icon: Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded), label: Text(_running ? 'Pausar' : 'Iniciar'), style: FilledButton.styleFrom(backgroundColor: _color, foregroundColor: const Color(0xFF061B1A), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14)))]),
      const SizedBox(height: 28), Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF10302E), borderRadius: BorderRadius.circular(18)), child: Text('Ciclo atual: $_cycles de 4 sessões de foco. Após quatro Pomodoros, a próxima pausa será mais longa.', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFC9DFD9), height: 1.5))),
    ])))));
  }
}

enum _Mode { focus, shortPause, longPause }
