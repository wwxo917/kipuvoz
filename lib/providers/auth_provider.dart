import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_providers.dart';

/// Sesión actual de Supabase Auth. Se actualiza cuando el usuario inicia o cierra sesión.
final sessionProvider = NotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);

class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() {
    final auth = ref.watch(supabaseClientProvider).auth;
    final sub = auth.onAuthStateChange.listen((data) {
      state = data.session;
    });
    ref.onDispose(sub.cancel);
    return auth.currentSession;
  }
}

/// Solo el id del usuario: así los datos no se recargan cada vez que se renueva el token.
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(sessionProvider.select((s) => s?.user.id));
});
