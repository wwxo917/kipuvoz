import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_error.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Crea la cuenta. Devuelve true si la sesión ya quedó iniciada
  /// (false si Supabase exige confirmar el correo primero).
  Future<bool> registrar(String correo, String contrasena) async {
    final res = await _client.auth.signUp(email: correo, password: contrasena);
    final user = res.user;
    // Con confirmación de correo activa, un correo repetido no da error: devuelve un usuario sin identidades.
    if (user != null && (user.identities?.isEmpty ?? false)) {
      throw const AppException('Este correo ya está registrado.');
    }
    return res.session != null;
  }

  Future<void> iniciarSesion(String correo, String contrasena) async {
    await _client.auth.signInWithPassword(email: correo, password: contrasena);
  }

  Future<void> cerrarSesion() async {
    await _client.auth.signOut();
  }
}
