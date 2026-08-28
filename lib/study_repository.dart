import 'package:supabase_flutter/supabase_flutter.dart';

class StudyRepository {
  StudyRepository._();
  static final _client = Supabase.instance.client;

  static String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null)
      throw const AuthException('Faça login para acessar seus estudos.');
    return id;
  }

  static Future<List<Map<String, dynamic>>> getSubjects() async =>
      List<Map<String, dynamic>>.from(
        await _client
            .from('disciplinas')
            .select()
            .eq('id_usuario', _userId)
            .order('nome'),
      );

  static Future<void> addSubject(String name) async => _client
      .from('disciplinas')
      .insert({'id_usuario': _userId, 'nome': name, 'cor_hex': '#7DE2C3'});

  static Future<void> updateSubject(int id, String name) async => _client
      .from('disciplinas')
      .update({'nome': name})
      .eq('id_disciplina', id)
      .eq('id_usuario', _userId);

  static Future<void> deleteSubject(int id) async => _client
      .from('disciplinas')
      .delete()
      .eq('id_disciplina', id)
      .eq('id_usuario', _userId);

  static Future<List<Map<String, dynamic>>> getTasks() async =>
      List<Map<String, dynamic>>.from(
        await _client
            .from('tarefas')
            .select()
            .eq('id_usuario', _userId)
            .order('data_entrega'),
      );

  static Future<void> addTask(String title, DateTime date) async =>
      _client.from('tarefas').insert({
        'id_usuario': _userId,
        'titulo': title,
        'data_entrega': date.toIso8601String(),
        'concluida': false,
      });

  static Future<void> deleteTask(int id) async => _client
      .from('tarefas')
      .delete()
      .eq('id_tarefa', id)
      .eq('id_usuario', _userId);

  static Future<String> _defaultDeckId() async {
    final existing = await _client
        .from('baralhos')
        .select('id')
        .eq('usuario_id', _userId)
        .eq('titulo', 'Meus flashcards')
        .maybeSingle();
    if (existing != null) return existing['id'] as String;
    final created = await _client
        .from('baralhos')
        .insert({'usuario_id': _userId, 'titulo': 'Meus flashcards'})
        .select('id')
        .single();
    return created['id'] as String;
  }

  static Future<List<Map<String, dynamic>>> getFlashcards() async {
    final deckId = await _defaultDeckId();
    return List<Map<String, dynamic>>.from(
      await _client
          .from('flashcards')
          .select()
          .eq('deck_id', deckId)
          .order('data_criacao'),
    );
  }

  static Future<void> addFlashcard(String question, String answer) async =>
      _client.from('flashcards').insert({
        'deck_id': await _defaultDeckId(),
        'pergunta': question,
        'resposta': answer,
      });

  static Future<void> deleteFlashcard(String id) async =>
      _client.from('flashcards').delete().eq('id', id);
}
