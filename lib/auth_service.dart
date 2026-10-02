import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final _auth = Supabase.instance.client.auth;

  static Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() => _auth.signOut();

  static String get displayName {
    final user = _auth.currentUser;
    final name = user?.userMetadata?['nome'] as String?;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return user?.email?.split('@').first ?? 'Estudante';
  }

  static Future<void> updateDisplayName(String name) =>
      _auth.updateUser(UserAttributes(data: {'nome': name.trim()}));

  static Future<void> signInWithGoogle() => _auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: kIsWeb ? 'http://localhost:3000/' : null,
  );

  static Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {'nome': name},
    );
    if (response.user == null) {
      throw const AuthException('O Supabase não retornou o usuário criado.');
    }
    return response;
  }
}
