// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studyapp/pagina1.dart';
import 'package:studyapp/pagina2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studyapp/study_session_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StudySessionStore.load();
  String? setupError;
  try {
    await dotenv.load(fileName: '.env');
    final url = dotenv.env['SUPABASE_URL'];
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (url == null || key == null || url.isEmpty || key.isEmpty) {
      throw StateError('As credenciais do Supabase não foram encontradas.');
    }
    await Supabase.initialize(url: url, anonKey: key);
  } catch (_) {
    setupError = 'Não foi possível iniciar a conexão com o Supabase. '
        'Confira o arquivo .env e execute flutter pub get.';
  }
  runApp(StudyApp(setupError: setupError));
}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key, this.setupError});
  final String? setupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study App',
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF061B1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7DE2C3),
          secondary: Color(0xFFB7F397),
          surface: Color(0xFF10302E),
        ),
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
      ),
      home: setupError == null
          ? Supabase.instance.client.auth.currentSession == null
              ? const Pagina1()
              : const Pagina2()
          : _SetupError(message: setupError!),
    );
  }
}

class _SetupError extends StatelessWidget {
  const _SetupError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF10302E),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cloud_off_rounded, size: 42, color: Color(0xFFFFC56B)),
              const SizedBox(height: 18),
              const Text('Não foi possível iniciar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFB4CBC6))),
            ]),
          ),
        ),
      ),
    ),
  );
}
