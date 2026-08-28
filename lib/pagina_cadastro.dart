import 'package:flutter/material.dart';
import 'package:studyapp/auth_service.dart';
import 'package:studyapp/logn_field.dart';
import 'package:studyapp/pagina2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaginaCadastro extends StatefulWidget {
  const PaginaCadastro({super.key});
  @override
  State<PaginaCadastro> createState() => _PaginaCadastroState();
}

class _PaginaCadastroState extends State<PaginaCadastro> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _loading = false;
  @override
  void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); _confirmPassword.dispose(); super.dispose(); }

  Future<void> _register() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _password.text.length < 6) {
      _show('Informe seu nome, e-mail e uma senha de pelo menos 6 caracteres.'); return;
    }
    if (_password.text != _confirmPassword.text) {
      _show('As senhas não coincidem.'); return;
    }
    setState(() => _loading = true);
    try {
      final response = await AuthService.signUp(
        name: _name.text.trim(),
        email: _email.text.trim().toLowerCase(),
        password: _password.text,
      );
      if (!mounted) return;
      if (response.session == null) {
        _show('O Supabase ainda exige confirmação por e-mail. Desative "Confirm email" no painel do projeto.');
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Pagina2()),
        (route) => false,
      );
    } on AuthException catch (error) {
      _show(_authError(error.message));
    } catch (_) {
      _show('Não foi possível conectar ao Supabase. Tente novamente.');
    }
    finally { if (mounted) setState(() => _loading = false); }
  }
  void _show(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  String _authError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('already registered')) return 'Este e-mail já possui uma conta.';
    if (normalized.contains('invalid')) return 'Informe um e-mail válido e uma senha segura.';
    if (normalized.contains('signup is disabled')) return 'O cadastro está desativado no Supabase.';
    return message;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: const Color(0xFF061B1A)),
    body: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430), child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: const Color(0xFF10302E), borderRadius: BorderRadius.circular(28)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Crie sua conta', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8), const Text('Comece a organizar seus estudos hoje.', style: TextStyle(color: Color(0xFFB4CBC6))),
          const SizedBox(height: 26),
          LoginField(hintText: 'Seu nome', controller: _name, icon: Icons.person_outline_rounded), const SizedBox(height: 14),
          LoginField(hintText: 'E-mail', controller: _email, icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress), const SizedBox(height: 14),
          LoginField(hintText: 'Senha (mínimo 6 caracteres)', controller: _password, icon: Icons.lock_outline_rounded, isPasswordField: !_showPassword, suffixIcon: _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, onPressed: () => setState(() => _showPassword = !_showPassword)),
          const SizedBox(height: 14),
          LoginField(hintText: 'Confirmar senha', controller: _confirmPassword, icon: Icons.lock_outline_rounded, isPasswordField: !_showConfirmPassword, suffixIcon: _showConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword)),
          const SizedBox(height: 22),
          FilledButton(onPressed: _loading ? null : _register, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7DE2C3), foregroundColor: const Color(0xFF061B1A), padding: const EdgeInsets.symmetric(vertical: 17)), child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF061B1A))) : const Text('Criar conta', style: TextStyle(fontWeight: FontWeight.w800))),
        ]),
      )),
    )),
  );
}
