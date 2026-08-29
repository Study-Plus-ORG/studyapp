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

  static Future<void> addSubject(String name, String planning) async => _client
      .from('disciplinas')
      .insert({
        'id_usuario': _userId,
        'nome': name,
        'planejamento': planning,
        'cor_hex': '#7DE2C3',
      });

  static Future<void> updateSubject(int id, String name, String planning) async => _client
      .from('disciplinas')
      .update({'nome': name, 'planejamento': planning})
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

  static Future<List<Map<String, dynamic>>> getDecks() async =>
      List<Map<String, dynamic>>.from(
        await _client
            .from('baralhos')
            .select()
            .eq('usuario_id', _userId)
            .order('criado_em'),
      );

  static Future<void> addDeck(String title) async => _client
      .from('baralhos')
      .insert({'usuario_id': _userId, 'titulo': title});

  static Future<void> deleteDeck(String id) async =>
      _client.from('baralhos').delete().eq('id', id).eq('usuario_id', _userId);

  static Future<List<Map<String, dynamic>>> getFlashcards(String deckId) async {
    return List<Map<String, dynamic>>.from(
      await _client
          .from('flashcards')
          .select()
          .eq('deck_id', deckId)
          .order('data_criacao'),
    );
  }

  static Future<int> getFlashcardCount() async =>
      (await _client.from('flashcards').select('id')).length;

  static Future<void> addFlashcard(
    String deckId,
    String question,
    String answer,
  ) => _client.from('flashcards').insert({
        'deck_id': deckId,
        'pergunta': question,
        'resposta': answer,
      });

  static Future<void> deleteFlashcard(String id) async =>
      _client.from('flashcards').delete().eq('id', id);
}
