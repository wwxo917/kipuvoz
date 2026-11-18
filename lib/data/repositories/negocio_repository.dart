import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/negocio.dart';

class NegocioRepository {
  NegocioRepository(this._db);

  final SupabaseClient _db;

  /// RLS devuelve solo el negocio del usuario autenticado (o ninguno).
  Future<Negocio?> obtener() async {
    final data = await _db.from('negocios').select().maybeSingle();
    return data == null ? null : Negocio.fromMap(data);
  }

  Future<Negocio> crear({required String nombre, required String tipo}) async {
    final data = await _db
        .from('negocios')
        .insert({'nombre': nombre.trim(), 'tipo': tipo, 'moneda': 'Bs'})
        .select()
        .single();
    return Negocio.fromMap(data);
  }

  Future<Negocio> actualizar(String id, {required String nombre, required String tipo}) async {
    final data = await _db
        .from('negocios')
        .update({'nombre': nombre.trim(), 'tipo': tipo})
        .eq('id', id)
        .select()
        .single();
    return Negocio.fromMap(data);
  }
}
