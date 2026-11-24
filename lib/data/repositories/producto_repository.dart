import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/producto.dart';

class ProductoRepository {
  ProductoRepository(this._db);

  final SupabaseClient _db;

  /// READ: productos activos del negocio (RLS filtra por usuario).
  Future<List<Producto>> listar() async {
    final data = await _db.from('productos').select().eq('activo', true).order('nombre');
    return data.map(Producto.fromMap).toList();
  }

  /// CREATE
  Future<void> crear(Producto p, {bool incluirCategoria = false}) async {
    await _db.from('productos').insert(p.toMap(incluirCategoria: incluirCategoria));
  }

  /// UPDATE
  Future<void> actualizar(String id, Producto p, {bool incluirCategoria = false}) async {
    await _db.from('productos').update(p.toMap(incluirCategoria: incluirCategoria)).eq('id', id);
  }

  /// Baja lógica: el producto se archiva, nunca se elimina.
  Future<void> archivar(String id) async {
    await _db.from('productos').update({'activo': false}).eq('id', id);
  }
}
