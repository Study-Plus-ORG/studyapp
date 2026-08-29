import 'package:flutter/material.dart';
import 'package:studyapp/study_repository.dart';

class Pagina5 extends StatefulWidget {
  const Pagina5({super.key});

  @override
  State<Pagina5> createState() => _Pagina5State();
}

class _Pagina5State extends State<Pagina5> {
  List<Map<String, dynamic>> _decks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    try {
      final decks = await StudyRepository.getDecks();
      if (mounted) setState(() => _decks = decks);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createDeck() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10302E),
        title: const Text('Criar baralho'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 100,
          decoration: InputDecoration(
            labelText: 'Nome do baralho',
            hintText: _decks.isEmpty ? 'Ex.: Química' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.isEmpty) return;
    try {
      await StudyRepository.addDeck(title);
      await _loadDecks();
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _openDeck(Map<String, dynamic> deck) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _DeckFlashcardsPage(
          deckId: deck['id'] as String,
          title: deck['titulo'] as String,
        ),
      ),
    );
    await _loadDecks();
  }

  Future<void> _deleteDeck(Map<String, dynamic> deck) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF10302E),
            title: const Text('Excluir baralho?'),
            content: Text(
              'Os flashcards de "${deck['titulo']}" também serão excluídos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    try {
      await StudyRepository.deleteDeck(deck['id'] as String);
      await _loadDecks();
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar baralhos: $error')),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Flashcards', style: TextStyle(fontWeight: FontWeight.w800))),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createDeck,
          backgroundColor: const Color(0xFF7DE2C3),
          foregroundColor: const Color(0xFF061B1A),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Baralho'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _decks.isEmpty
                    ? const _EmptyDecks()
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _decks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) => _DeckTile(
                          title: _decks[index]['titulo'] as String,
                          onTap: () => _openDeck(_decks[index]),
                          onDelete: () => _deleteDeck(_decks[index]),
                        ),
                      ),
          ),
        ),
      );
}

class _EmptyDecks extends StatelessWidget {
  const _EmptyDecks();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style_outlined, size: 56, color: Color(0xFF7DE2C3)),
            SizedBox(height: 20),
            Text('Crie seu primeiro baralho', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text('Organize os flashcards por matéria ou assunto.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB4CBC6))),
          ],
        ),
      );
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({required this.title, required this.onTap, required this.onDelete});
  final String title;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF10302E),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(color: const Color(0xFFFFC56B).withValues(alpha: .14), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.style_rounded, color: Color(0xFFFFC56B)),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Excluir baralho',
                ),
                const Icon(Icons.arrow_forward_rounded, color: Color(0xFF7DE2C3)),
              ],
            ),
          ),
        ),
      );
}

class _DeckFlashcardsPage extends StatefulWidget {
  const _DeckFlashcardsPage({required this.deckId, required this.title});
  final String deckId;
  final String title;

  @override
  State<_DeckFlashcardsPage> createState() => _DeckFlashcardsPageState();
}

class _DeckFlashcardsPageState extends State<_DeckFlashcardsPage> {
  List<_Flashcard> _cards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      final rows = await StudyRepository.getFlashcards(widget.deckId);
      if (mounted) {
        setState(() {
          _cards = rows
              .map((row) => _Flashcard(row['id'] as String, row['pergunta'] as String, row['resposta'] as String))
              .toList();
        });
      }
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createCard() async {
    final questionController = TextEditingController();
    final answerController = TextEditingController();
    final question = await _askQuestion(questionController);
    if (question == null) {
      questionController.dispose();
      answerController.dispose();
      return;
    }
    final answer = await _askAnswer(question, answerController);
    questionController.dispose();
    answerController.dispose();
    if (answer == null) return;
    try {
      await StudyRepository.addFlashcard(widget.deckId, question, answer);
      await _loadCards();
    } catch (error) {
      _showError(error);
    }
  }

  Future<String?> _askQuestion(TextEditingController controller) => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF10302E),
          title: const Text('Novo flashcard'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 350,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Pergunta', hintText: 'Digite a pergunta'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Avançar')),
          ],
        ),
      ).then((value) => value == null || value.isEmpty ? null : value);

  Future<String?> _askAnswer(String question, TextEditingController controller) => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF10302E),
          title: const Text('Resposta do flashcard'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question, style: const TextStyle(color: Color(0xFFC9DFD9))),
                const SizedBox(height: 20),
                TextField(controller: controller, autofocus: true, maxLength: 250, maxLines: 4, decoration: const InputDecoration(labelText: 'Resposta')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Criar')),
          ],
        ),
      ).then((value) => value == null || value.isEmpty ? null : value);

  Future<void> _deleteCard(_Flashcard card) async {
    try {
      await StudyRepository.deleteFlashcard(card.id);
      await _loadCards();
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar flashcard: $error')),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800))),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createCard,
          backgroundColor: const Color(0xFF7DE2C3),
          foregroundColor: const Color(0xFF061B1A),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Flashcard'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _cards.isEmpty
                    ? const _EmptyCards()
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _cards.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) => _FlashcardTile(card: _cards[index], index: index, onDelete: () => _deleteCard(_cards[index])),
                      ),
          ),
        ),
      );
}

class _EmptyCards extends StatelessWidget {
  const _EmptyCards();

  @override
  Widget build(BuildContext context) => const Center(
        child: Text('Ainda não há flashcards neste baralho.', style: TextStyle(color: Color(0xFFB4CBC6))),
      );
}

class _FlashcardTile extends StatefulWidget {
  const _FlashcardTile({required this.card, required this.index, required this.onDelete});
  final _Flashcard card;
  final int index;
  final VoidCallback onDelete;

  @override
  State<_FlashcardTile> createState() => _FlashcardTileState();
}

class _FlashcardTileState extends State<_FlashcardTile> {
  bool _answerVisible = false;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF10302E), borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${widget.index + 1}', style: const TextStyle(color: Color(0xFF7DE2C3), fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(onPressed: widget.onDelete, icon: const Icon(Icons.delete_outline_rounded), tooltip: 'Remover'),
              ],
            ),
            const SizedBox(height: 10),
            Text(widget.card.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            if (_answerVisible) Text(widget.card.answer, style: const TextStyle(color: Color(0xFFC9DFD9), height: 1.45)),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _answerVisible = !_answerVisible),
                icon: Icon(_answerVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                label: Text(_answerVisible ? 'Ocultar resposta' : 'Ver resposta'),
              ),
            ),
          ],
        ),
      );
}

class _Flashcard {
  const _Flashcard(this.id, this.question, this.answer);
  final String id;
  final String question;
  final String answer;
}
