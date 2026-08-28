import 'package:flutter/material.dart';
import 'package:studyapp/auth_service.dart';
import 'package:studyapp/logn_field.dart';
import 'package:studyapp/pagina2.dart';
import 'package:studyapp/pagina_cadastro.dart';

class Pagina1 extends StatefulWidget {
  const Pagina1({super.key});
  @override
  State<Pagina1> createState() => _Pagina1State();
}

class _Pagina1State extends State<Pagina1> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      _message('Preencha seu e-mail e senha.'); return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.signIn(email: _email.text.trim(), password: _password.text);
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Pagina2()));
    } catch (_) {
      _message('Não foi possível entrar. Confira seus dados e tente novamente.');
    } finally { if (mounted) setState(() => _loading = false); }
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: const Color(0xFF10302E), borderRadius: BorderRadius.circular(28)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const _Brand(),
              const SizedBox(height: 32),
              const Text('Boas-vindas de volta', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Entre para continuar o seu plano de estudos.', style: TextStyle(color: Color(0xFFB4CBC6))),
              const SizedBox(height: 26),
              LoginField(hintText: 'E-mail', controller: _email, icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              LoginField(hintText: 'Senha', controller: _password, icon: Icons.lock_outline_rounded, isPasswordField: !_showPassword, suffixIcon: _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, onPressed: () => setState(() => _showPassword = !_showPassword)),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _loading ? null : _login,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7DE2C3), foregroundColor: const Color(0xFF061B1A), padding: const EdgeInsets.symmetric(vertical: 17)),
                child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF061B1A))) : const Text('Entrar', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 18),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Ainda não tem uma conta?', style: TextStyle(color: Color(0xFFB4CBC6))),
                TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaginaCadastro())), child: const Text('Cadastre-se')),
              ]),
            ]),
          ),
        ),
      ),
    ),
  );
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    CircleAvatar(backgroundColor: Color(0xFF7DE2C3), foregroundColor: Color(0xFF061B1A), child: Icon(Icons.school_rounded)),
    SizedBox(width: 10), Text('Study', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
  ]);
}
