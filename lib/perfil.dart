import 'package:flutter/material.dart';
import 'package:studyapp/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late final TextEditingController _name;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: AuthService.displayName);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe seu nome.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await AuthService.updateDisplayName(name);
      if (mounted) Navigator.pop(context, name);
    } on AuthException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível atualizar o perfil.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: const Color(0xFF10302E), borderRadius: BorderRadius.circular(24)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const CircleAvatar(radius: 34, backgroundColor: Color(0xFF7DE2C3), foregroundColor: Color(0xFF061B1A), child: Icon(Icons.person_rounded, size: 34)),
                const SizedBox(height: 22),
                TextField(controller: _name, autofocus: true, maxLength: 80, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person_outline_rounded))),
                const SizedBox(height: 8),
                Text('E-mail: $email', style: const TextStyle(color: Color(0xFFB4CBC6))),
                const SizedBox(height: 24),
                FilledButton(onPressed: _saving ? null : _save, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7DE2C3), foregroundColor: const Color(0xFF061B1A), padding: const EdgeInsets.symmetric(vertical: 16)), child: _saving ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF061B1A))) : const Text('Salvar alterações', style: TextStyle(fontWeight: FontWeight.w800))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
