import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Agenda lembretes locais para os prazos que pertencem ao usuário logado.
class DeadlineNotifications {
  DeadlineNotifications._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static bool _available = true;

  static Future<void> initialize() async {
    if (_ready) return;
    try {
      tz.initializeTimeZones();
      // O app é direcionado ao público brasileiro; evita agendamentos em UTC.
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings: settings);
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      _ready = true;
    } catch (_) {
      _available = false;
    }
  }

  static Future<void> schedule({
    required int taskId,
    required String title,
    required DateTime deadline,
  }) async {
    await initialize();
    if (!_available) return;
    final reminder = deadline.subtract(const Duration(days: 1));
    // Não mostra um lembrete atrasado quando a atividade foi criada em cima da hora.
    if (!reminder.isAfter(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id: taskId,
        title: 'Prazo amanhã',
        body: 'A atividade "$title" vence amanhã.',
        scheduledDate: tz.TZDateTime.from(reminder, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'deadlines',
            'Prazos de atividades',
            channelDescription: 'Lembretes de atividades próximas do prazo',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {}
  }

  static Future<void> cancel(int taskId) async {
    await initialize();
    if (!_available) return;
    try {
      await _plugin.cancel(id: taskId);
    } catch (_) {}
  }
}
