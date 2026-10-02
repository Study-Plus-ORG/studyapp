import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudySession {
  const StudySession({required this.finishedAt, required this.duration});
  final DateTime finishedAt;
  final Duration duration;
}

/// Mantém e restaura as sessões concluídas no dispositivo.
class StudySessionStore {
  StudySessionStore._();
  static final ValueNotifier<List<StudySession>> sessions = ValueNotifier<List<StudySession>>([]);
  static const _storageKey = 'study_sessions';
  static SharedPreferences? _preferences;

  static Future<void> load() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      final saved = _preferences!.getStringList(_storageKey) ?? [];
      final loaded = <StudySession>[];
      for (final item in saved) {
        try {
          final data = jsonDecode(item) as Map<String, dynamic>;
          loaded.add(StudySession(
            finishedAt: DateTime.parse(data['finishedAt'] as String),
            duration: Duration(seconds: data['seconds'] as int),
          ));
        } catch (_) {}
      }
      sessions.value = loaded;
    } catch (_) {
      // O aplicativo continua funcionando mesmo sem armazenamento local.
    }
  }

  static void addFocusSession(Duration duration) {
    sessions.value = [...sessions.value, StudySession(finishedAt: DateTime.now(), duration: duration)];
    _save();
  }

  static Future<void> _save() async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    _preferences = preferences;
    await preferences.setStringList(
      _storageKey,
      sessions.value.map((session) => jsonEncode({
        'finishedAt': session.finishedAt.toIso8601String(),
        'seconds': session.duration.inSeconds,
      })).toList(),
    );
  }

  static bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year && first.month == second.month && first.day == second.day;

  static Duration focusOn(DateTime day, [List<StudySession>? source]) => (source ?? sessions.value)
      .where((session) => _isSameDay(session.finishedAt, day))
      .fold(Duration.zero, (total, session) => total + session.duration);

  static int completedOn(DateTime day, [List<StudySession>? source]) => (source ?? sessions.value)
      .where((session) => _isSameDay(session.finishedAt, day)).length;
}
