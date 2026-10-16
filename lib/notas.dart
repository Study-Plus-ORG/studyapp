import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studyapp/study_repository.dart';

class NotasPage extends StatefulWidget {
  const NotasPage({super.key});
  @override State<NotasPage> createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {
  List<Map<String, dynamic>> _notes = [];
  bool _loading = true;
  String _query = '';

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { _notes = await StudyRepository.getNotes(); } catch (error) {
      if (mounted) _message('Não foi possível carregar as notas: $error');
    }
    if (mounted) setState(() => _loading = false);
  }
  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _create() async {
    try {
      final note = await StudyRepository.createNote('Nova nota');
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)));
      _load();
    } catch (error) {
      if (mounted) {
        _message('Não foi possível criar a nota: $error');
      }
    }
  }

  @override Widget build(BuildContext context) {
    final notes = _notes.where((note) {
      final searchable = '${note['titulo'] ?? ''} ${note['conteudo'] ?? ''}'.toLowerCase();
      return searchable.contains(_query.toLowerCase());
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Notas', style: TextStyle(fontWeight: FontWeight.w800))),
      floatingActionButton: FloatingActionButton.extended(onPressed: _create, icon: const Icon(Icons.edit_note_rounded), label: const Text('Nova nota')),
      body: Padding(padding: const EdgeInsets.all(20), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1050), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Suas anotações', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6), const Text('Capture ideias, resumos e listas de revisão.', style: TextStyle(color: Color(0xFFB4CBC6))),
        const SizedBox(height: 20),
        TextField(onChanged: (value) => setState(() => _query = value), decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: 'Pesquisar nas notas', filled: true, fillColor: const Color(0xFF10302E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
        const SizedBox(height: 20),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : notes.isEmpty ? _EmptyNotes(onCreate: _create) : GridView.builder(gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 260, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1.05), itemCount: notes.length, itemBuilder: (_, index) => _NoteCard(note: notes[index], onOpen: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorPage(note: notes[index]))); _load(); }))),
      ])))),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.onCreate}); final VoidCallback onCreate;
  @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.sticky_note_2_outlined, size: 52, color: Color(0xFF7DE2C3)), const SizedBox(height: 14), const Text('Nenhuma nota por aqui', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Crie uma nota para guardar seus estudos.', style: TextStyle(color: Color(0xFFB4CBC6))), const SizedBox(height: 16), OutlinedButton.icon(onPressed: onCreate, icon: const Icon(Icons.add), label: const Text('Criar nota'))]));
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onOpen}); final Map<String, dynamic> note; final VoidCallback onOpen;
  @override Widget build(BuildContext context) {
    final style = Map<String, dynamic>.from(note['estilo'] ?? {}); final color = _colorFrom(style['color'] as String?);
    final content = note['conteudo'] as String? ?? '';
    return Material(color: color, borderRadius: BorderRadius.circular(20), child: InkWell(onTap: onOpen, borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.note_alt_outlined, color: color.computeLuminance() > .45 ? const Color(0xFF24534A) : Colors.white70), const Spacer(), Text(note['titulo'] as String? ?? 'Sem título', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 7), Text(content.isEmpty ? 'Toque para escrever' : content, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: color.computeLuminance() > .45 ? const Color(0xFF315F56) : Colors.white70, height: 1.35))]))));
  }
}

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, required this.note}); final Map<String, dynamic> note;
  @override State<NoteEditorPage> createState() => _NoteEditorPageState();
}
class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  late final FocusNode _contentFocus;
  late Map<String, dynamic> _style;
  late List<dynamic> _drawing;
  late Color _ink;
  bool _drawingMode = false;
  Timer? _timer; bool _saving = false;
  @override void initState() {
    super.initState();
    _title = TextEditingController(text: widget.note['titulo'] as String? ?? '');
    _content = TextEditingController(text: widget.note['conteudo'] as String? ?? '');
    _contentFocus = FocusNode();
    _style = Map<String, dynamic>.from(widget.note['estilo'] ?? {});
    _drawing = List<dynamic>.from(widget.note['desenho'] ?? []);
    _ink = _colorFrom(_style['inkColor'] as String? ?? '#163E37');
    _title.addListener(_scheduleSave);
    _content.addListener(_scheduleSave);
  }
  @override void dispose() { _timer?.cancel(); _title.dispose(); _content.dispose(); _contentFocus.dispose(); super.dispose(); }
  void _scheduleSave() { _timer?.cancel(); _timer = Timer(const Duration(milliseconds: 650), _save); }
  Future<void> _saveNow() async { _timer?.cancel(); await _save(); }
  Future<void> _save() async {
    if (_saving) return; _saving = true;
    try { await StudyRepository.updateNote(id: widget.note['id'].toString(), title: _title.text.trim().isEmpty ? 'Sem título' : _title.text.trim(), content: _content.text, style: _style, drawing: _drawing); }
    finally { _saving = false; if (mounted) setState(() {}); }
  }
  Future<void> _delete() async { final yes = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Excluir nota?'), content: const Text('Esta ação não pode ser desfeita.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir'))])); if (yes == true) { await StudyRepository.deleteNote(widget.note['id'].toString()); if (mounted) Navigator.pop(context); } }
  Future<void> _openDrawing() async {
    final drawing = await Navigator.push<List<dynamic>>(context, MaterialPageRoute(builder: (_) => DrawingPage(initialDrawing: _drawing, paperColor: _colorFrom(_style['color'] as String?))));
    if (drawing != null && mounted) {
      setState(() => _drawing = drawing);
      await _saveNow();
    }
  }
  Future<void> _chooseInkColor() async {
    final color = await showDialog<Color>(context: context, builder: (_) => _ColorWheelDialog(initialColor: _ink));
    if (color != null && mounted) {
      setState(() { _ink = color; _style['inkColor'] = _hexFromColor(color); });
      _scheduleSave();
    }
  }
  void _toggleDrawing() {
    setState(() => _drawingMode = !_drawingMode);
    if (_drawingMode) { _contentFocus.unfocus(); } else { _contentFocus.requestFocus(); }
  }
  @override Widget build(BuildContext context) { final color = _colorFrom(_style['color'] as String?); return Scaffold(appBar: AppBar(actions: [Text(_saving ? 'Salvando…' : 'Salvo', style: const TextStyle(color: Color(0xFFB4CBC6), fontSize: 12)), IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline_rounded), tooltip: 'Excluir nota'), const SizedBox(width: 8)]), body: Container(color: color, child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(22, 12, 22, 28), child: Column(children: [Row(children: [IconButton(onPressed: () async { await _saveNow(); if (mounted) Navigator.pop(context); }, icon: const Icon(Icons.arrow_back)), const Spacer(), IconButton(onPressed: _toggleDrawing, icon: _drawingMode ? const Text('Aa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)) : const Icon(Icons.draw_rounded), tooltip: _drawingMode ? 'Voltar a escrever' : 'Desenhar'), IconButton(onPressed: _chooseInkColor, icon: Container(width: 22, height: 22, decoration: BoxDecoration(color: _ink, shape: BoxShape.circle, border: Border.all(color: Colors.black26))), tooltip: 'Cor da letra e caneta'), ...['#FFF5B1', '#D7F7EE', '#DCE8FF', '#F8D4E4', '#FFFFFF'].map((hex) => GestureDetector(onTap: () { setState(() => _style['color'] = hex); _scheduleSave(); }, child: Container(width: 28, height: 28, margin: const EdgeInsets.only(left: 8), decoration: BoxDecoration(color: _colorFrom(hex), shape: BoxShape.circle, border: Border.all(color: Colors.black26)))))]), TextField(controller: _title, maxLines: 2, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _ink), decoration: const InputDecoration(hintText: 'Título', border: InputBorder.none)), const Divider(color: Color(0x3324544C)), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Stack(children: [Positioned.fill(child: CustomPaint(painter: _DottedPaperPainter())), Positioned.fill(child: Padding(padding: const EdgeInsets.all(14), child: TextField(focusNode: _contentFocus, controller: _content, readOnly: _drawingMode, maxLines: null, expands: true, textAlignVertical: TextAlignVertical.top, style: TextStyle(fontSize: (_style['fontSize'] as num?)?.toDouble() ?? 18, height: 1.55, color: _ink), decoration: const InputDecoration(hintText: 'Comece a escrever…', border: InputBorder.none)))), Positioned.fill(child: IgnorePointer(ignoring: !_drawingMode, child: _InlineDrawingCanvas(drawing: _drawing, ink: _ink, onChanged: (drawing) { setState(() => _drawing = drawing); _scheduleSave(); })))]))), Row(children: [IconButton(onPressed: () { setState(() => _style['fontSize'] = 16); _scheduleSave(); }, icon: const Icon(Icons.text_decrease_rounded)), IconButton(onPressed: () { setState(() => _style['fontSize'] = 22); _scheduleSave(); }, icon: const Icon(Icons.text_increase_rounded)), if (_drawingMode) const Text('Modo desenho', style: TextStyle(color: Color(0xFF35675E), fontSize: 12)), const Spacer(), const Icon(Icons.cloud_done_outlined, color: Color(0xFF35675E), size: 19), const SizedBox(width: 6), const Text('Salvamento automático', style: TextStyle(color: Color(0xFF35675E), fontSize: 12))])]))))); }
}

class _InlineDrawingCanvas extends StatefulWidget {
  const _InlineDrawingCanvas({required this.drawing, required this.ink, required this.onChanged});
  final List<dynamic> drawing;
  final Color ink;
  final ValueChanged<List<dynamic>> onChanged;
  @override State<_InlineDrawingCanvas> createState() => _InlineDrawingCanvasState();
}

class _InlineDrawingCanvasState extends State<_InlineDrawingCanvas> {
  late List<_Stroke> _strokes;
  _Stroke? _activeStroke;
  @override void initState() { super.initState(); _strokes = widget.drawing.map(_Stroke.fromJson).whereType<_Stroke>().toList(); }
  void _start(DragStartDetails details) => setState(() { _activeStroke = _Stroke(color: widget.ink, width: 4, points: [details.localPosition]); _strokes.add(_activeStroke!); });
  void _draw(DragUpdateDetails details) => setState(() => _activeStroke?.points.add(details.localPosition));
  void _end(DragEndDetails details) { _activeStroke = null; widget.onChanged(_strokes.map((stroke) => stroke.toJson()).toList()); }
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, constraints) => GestureDetector(behavior: HitTestBehavior.opaque, onPanStart: _start, onPanUpdate: _draw, onPanEnd: _end, child: CustomPaint(size: Size(constraints.maxWidth, constraints.maxHeight), painter: _DrawingPainter(_strokes))));
}

class _DottedPaperPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) { final dot = Paint()..color = const Color(0xFF70928B).withOpacity(.42); for (double y = 12; y < size.height; y += 20) { for (double x = 12; x < size.width; x += 20) { canvas.drawCircle(Offset(x, y), 1.1, dot); } } }
  @override bool shouldRepaint(covariant _DottedPaperPainter oldDelegate) => false;
}

class _ColorWheelDialog extends StatefulWidget {
  const _ColorWheelDialog({required this.initialColor}); final Color initialColor;
  @override State<_ColorWheelDialog> createState() => _ColorWheelDialogState();
}

class _ColorWheelDialogState extends State<_ColorWheelDialog> {
  late Color _color;
  @override void initState() { super.initState(); _color = widget.initialColor; }
  @override Widget build(BuildContext context) => AlertDialog(title: const Text('Escolha uma cor'), content: SizedBox(width: 250, height: 250, child: _ColorWheel(color: _color, onChanged: (color) => setState(() => _color = color))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, _color), child: const Text('Usar cor'))]);
}

class _ColorWheel extends StatelessWidget {
  const _ColorWheel({required this.color, required this.onChanged}); final Color color; final ValueChanged<Color> onChanged;
  void _pick(Offset position, Size size) { final center = size.center(Offset.zero); final vector = position - center; final radius = size.shortestSide / 2; final distance = vector.distance; if (distance > radius) return; final hue = (math.atan2(vector.dy, vector.dx) * 180 / math.pi + 360) % 360; final saturation = (distance / radius).clamp(0.0, 1.0).toDouble(); onChanged(HSLColor.fromAHSL(1, hue, saturation, .5).toColor()); }
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, constraints) { final size = Size(constraints.maxWidth, constraints.maxHeight); return GestureDetector(onTapDown: (details) => _pick(details.localPosition, size), onPanUpdate: (details) => _pick(details.localPosition, size), child: CustomPaint(painter: _ColorWheelPainter(selected: color), size: size)); });
}

class _ColorWheelPainter extends CustomPainter {
  const _ColorWheelPainter({required this.selected}); final Color selected;
  @override void paint(Canvas canvas, Size size) { final center = size.center(Offset.zero); final radius = size.shortestSide / 2; final paint = Paint(); for (var degrees = 0; degrees < 360; degrees++) { final hue = degrees.toDouble(); paint.color = HSLColor.fromAHSL(1, hue, 1, .5).toColor(); canvas.drawArc(Rect.fromCircle(center: center, radius: radius), hue * math.pi / 180, math.pi / 180 + .02, true, paint); } final hsl = HSLColor.fromColor(selected); final angle = hsl.hue * math.pi / 180; final marker = center + Offset(math.cos(angle), math.sin(angle)) * radius * hsl.saturation; canvas.drawCircle(marker, 11, Paint()..color = Colors.white); canvas.drawCircle(marker, 8, Paint()..color = selected); }
  @override bool shouldRepaint(covariant _ColorWheelPainter oldDelegate) => oldDelegate.selected != selected;
}

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key, required this.initialDrawing, required this.paperColor});
  final List<dynamic> initialDrawing;
  final Color paperColor;
  @override State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  late List<_Stroke> _strokes;
  _Stroke? _activeStroke;
  Color _ink = const Color(0xFF163E37);
  double _width = 4;
  @override void initState() { super.initState(); _strokes = widget.initialDrawing.map(_Stroke.fromJson).whereType<_Stroke>().toList(); }
  List<dynamic> get _serialized => _strokes.map((stroke) => stroke.toJson()).toList();
  void _start(DragStartDetails details) => setState(() { _activeStroke = _Stroke(color: _ink, width: _width, points: [details.localPosition]); _strokes.add(_activeStroke!); });
  void _draw(DragUpdateDetails details) => setState(() => _activeStroke?.points.add(details.localPosition));
  void _end(DragEndDetails details) => _activeStroke = null;
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Desenho'), actions: [IconButton(onPressed: _strokes.isEmpty ? null : () => setState(() => _strokes.removeLast()), icon: const Icon(Icons.undo_rounded), tooltip: 'Desfazer'), IconButton(onPressed: _strokes.isEmpty ? null : () => setState(_strokes.clear), icon: const Icon(Icons.delete_sweep_outlined), tooltip: 'Limpar'), TextButton(onPressed: () => Navigator.pop(context, _serialized), child: const Text('Concluir'))]),
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Container(color: widget.paperColor, child: LayoutBuilder(builder: (_, constraints) => GestureDetector(onPanStart: _start, onPanUpdate: _draw, onPanEnd: _end, child: CustomPaint(size: Size(constraints.maxWidth, constraints.maxHeight), painter: _DrawingPainter(_strokes))))))),
      const SizedBox(height: 14),
      Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [const Text('Caneta', style: TextStyle(fontWeight: FontWeight.w700)), ...[const Color(0xFF163E37), const Color(0xFF1769AA), const Color(0xFFC62828), const Color(0xFF7B1FA2)].map((color) => GestureDetector(onTap: () => setState(() => _ink = color), child: Container(width: 30, height: 30, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: _ink == color ? Colors.white : Colors.transparent, width: 3))))), Icon(Icons.line_weight_rounded, color: _ink), SizedBox(width: 110, child: Slider(value: _width, min: 2, max: 12, divisions: 5, onChanged: (value) => setState(() => _width = value)))])
    ])),
  ));
}

class _Stroke {
  _Stroke({required this.color, required this.width, required this.points});
  final Color color; final double width; final List<Offset> points;
  static _Stroke? fromJson(dynamic value) { if (value is! Map) return null; final rawPoints = value['points']; if (rawPoints is! List) return null; final points = rawPoints.whereType<Map>().map((point) { final x = point['x']; final y = point['y']; return x is num && y is num ? Offset(x.toDouble(), y.toDouble()) : null; }).whereType<Offset>().toList(); if (points.isEmpty) return null; return _Stroke(color: _colorFrom(value['color'] as String?), width: (value['width'] as num?)?.toDouble() ?? 4, points: points); }
  Map<String, dynamic> toJson() => {'color': '#${color.value.toRadixString(16).substring(2).padLeft(6, '0').toUpperCase()}', 'width': width, 'points': points.map((point) => {'x': point.dx, 'y': point.dy}).toList()};
}

class _DrawingPainter extends CustomPainter {
  const _DrawingPainter(this.strokes); final List<_Stroke> strokes;
  @override void paint(Canvas canvas, Size size) { for (final stroke in strokes) { final paint = Paint()..color = stroke.color..strokeWidth = stroke.width..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke; if (stroke.points.length == 1) { canvas.drawCircle(stroke.points.first, stroke.width / 2, paint); continue; } final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy); for (final point in stroke.points.skip(1)) { path.lineTo(point.dx, point.dy); } canvas.drawPath(path, paint); } }
  @override bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}

Color _colorFrom(String? hex) { final raw = (hex ?? '#D7F7EE').replaceAll('#', ''); return Color(int.parse('FF$raw', radix: 16)); }
String _hexFromColor(Color color) => '#${color.value.toRadixString(16).substring(2).padLeft(6, '0').toUpperCase()}';
