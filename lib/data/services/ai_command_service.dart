import 'package:supabase_flutter/supabase_flutter.dart';

/// Acceso seguro a un servicio de IA: el token del usuario va a Supabase.
/// La clave del proveedor de IA SOLO vive en los secretos de la Edge Function.
class AiCommandService {
  AiCommandService(this.client);
  final SupabaseClient client;

  /// Devuelve null cuando la Edge Function todavía no fue desplegada/configurada.
  /// El llamador muestra un aviso y usa un intérprete local determinista.
  Future<Map<String, dynamic>?> interpretar(String frase) async {
    if (client.auth.currentSession == null) return null;
    try {
      final response = await client.functions.invoke(
        'interpretar-comando', body: {'texto': frase},
      ).timeout(const Duration(seconds: 12));
      if (response.status != 200) return null;
      final data = response.data;
      if (data is Map<String, dynamic> && data['tipo'] != null) return data;
      return null;
    } catch (_) {
      return null;
    }
  }
}
