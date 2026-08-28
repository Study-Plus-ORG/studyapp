import 'package:flutter/material.dart';
import 'package:studyapp/study_repository.dart';

class Pagina5 extends StatefulWidget {
  const Pagina5({super.key});
  @override
  State<Pagina5> createState() => _Pagina5State();
}

class _Pagina5State extends State<Pagina5> {
  final List<_Flashcard> _cards = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadCards(); }

  Future<void> _loadCards() async {
    try {
      final rows = await StudyRepository.getFlashcards();
      if (mounted) setState(() { _cards
        ..clear()
        ..addAll(rows.map((row) => _Flashcard(row['id'] as String, row['pergunta'] as String, row['resposta'] as String))); _loading = false; });
    } catch (error) { if (mounted) { setState(() => _loading = false); _showError(error); } }
  }

  Future<void> _createCard() async {
    final question = TextEditingController();
    final answer = TextEditingController();
    final hasQuestion = await _askQuestion(question);
    if (!hasQuestion) {
      question.dispose();
      answer.dispose();
      return;
    }
    final card = await _askAnswer(question.text.trim(), answer);
    if (card != null) {
      try { await StudyRepository.addFlashcard(card.question, card.answer); await _loadCards(); }
      catch (error) { _showError(error); }
    }
    question.dispose();
    answer.dispose();
  }

  Future<bool> _askQuestion(TextEditingController question) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF10302E),
          title: const Text('Novo flashcard'),
          content: SizedBox(
            width: 420,
            child: TextField(
              controller: question,
              autofocus: true,
              maxLength: 350,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Pergunta',
                hintText: 'Digite a pergunta',
                counterText: 'Máximo: 350 caracteres',
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, question.text.trim().isNotEmpty), child: const Text('Avançar')),
          ],
        ),
      ) ??
      false;

  Future<_Flashcard?> _askAnswer(String question, TextEditingController answer) => showDialog<_Flashcard>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF10302E),
      title: const Text('Resposta do flashcard'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(alignment: Alignment.centerLeft, child: Text('Pergunta', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xFF7DE2C3)))),
          const SizedBox(height: 6),
          Align(alignment: Alignment.centerLeft, child: Text(question, style: const TextStyle(color: Color(0xFFC9DFD9)))),
          const SizedBox(height: 22),
          TextField(
            controller: answer,
            autofocus: true,
            maxLength: 250,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Resposta', hintText: 'Digite a resposta', counterText: 'Máximo: 250 caracteres'),
          ),
        ])),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, answer.text.trim().isEmpty ? null : _Flashcard('', question, answer.text.trim())), child: const Text('Criar')),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Flashcards', style: TextStyle(fontWeight: FontWeight.w800))),
    floatingActionButton: FloatingActionButton.extended(onPressed: _createCard, backgroundColor: const Color(0xFF7DE2C3), foregroundColor: const Color(0xFF061B1A), icon: const Icon(Icons.add_rounded), label: const Text('Flashcard')),
    body: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: _loading ? const Center(child: CircularProgressIndicator()) : _cards.isEmpty ? const _EmptyFlashcards() : ListView.separated(
        padding: const EdgeInsets.all(20), itemCount: _cards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) => _FlashcardTile(card: _cards[index], index: index, onDelete: () => _deleteCard(_cards[index])),
      ),
    )),
  );

  Future<void> _deleteCard(_Flashcard card) async {
    try { await StudyRepository.deleteFlashcard(card.id); await _loadCards(); }
    catch (error) { _showError(error); }
  }
  void _showError(Object error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar flashcard: $error')));
}

class _EmptyFlashcards extends StatelessWidget {
  const _EmptyFlashcards();
  @override
  Widget build(BuildContext context) => const Padding(padding: EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.style_outlined, size: 56, color: Color(0xFF7DE2C3)), SizedBox(height: 20),
    Text('Crie seu primeiro flashcard', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)), SizedBox(height: 8),
    Text('Use o botão “Flashcard” para criar perguntas e revisar seus conteúdos.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB4CBC6))),
  ]));
}

class _FlashcardTile extends StatefulWidget {
  const _FlashcardTile({required this.card, required this.index, required this.onDelete});
  final _Flashcard card; final int index; final VoidCallback onDelete;
  @override State<_FlashcardTile> createState() => _FlashcardTileState();
}

class _FlashcardTileState extends State<_FlashcardTile> {
  bool _answerVisible = false;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF10302E), borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF7DE2C3).withValues(alpha: .14), borderRadius: BorderRadius.circular(10)), child: Text('${widget.index + 1}', style: const TextStyle(color: Color(0xFF7DE2C3), fontWeight: FontWeight.w800))), const Spacer(), IconButton(onPressed: widget.onDelete, icon: const Icon(Icons.delete_outline_rounded), tooltip: 'Remover')]),
      const SizedBox(height: 10), Text(widget.card.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 14),
      if (_answerVisible) Text(widget.card.answer, style: const TextStyle(color: Color(0xFFC9DFD9), height: 1.45)),
      Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () => setState(() => _answerVisible = !_answerVisible), icon: Icon(_answerVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined), label: Text(_answerVisible ? 'Ocultar resposta' : 'Ver resposta'))),
    ]),
  );
}

class _Flashcard { const _Flashcard(this.id, this.question, this.answer); final String id; final String question; final String answer; }
