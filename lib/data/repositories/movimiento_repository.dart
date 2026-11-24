import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/movimiento.dart';

class MovimientoRepository {
  MovimientoRepository(this._db);

  final SupabaseClient _db;

  /// READ: movimientos con sus productos, del más reciente al más antiguo.
  Future<List<Movimiento>> listar({int limite = 200}) async {
    final data = await _db
        .from('movimientos')
        .select('*, movimiento_items(cantidad, precio_unitario, productos(nombre))')
        .order('fecha', ascending: false)
        .limit(limite);
    return data.map(Movimiento.fromMap).toList();
  }

  /// CREATE: usa la función registrar_movimiento, que guarda el movimiento, sus ítems
  /// y actualiza el stock en una sola transacción.
  Future<void> registrar({
    required TipoMovimiento tipo,
    List<LineaMovimiento> lineas = const [],
    String? concepto,
    double? total,
  }) async {
    final params = <String, dynamic>{'p_tipo': tipo.name};
    if (tipo == TipoMovimiento.gasto) {
      params['p_concepto'] = concepto?.trim();
      params['p_total'] = total;
    } else {
      params['p_items'] = lineas.map((l) => l.toMap()).toList();
    }
    await _db.rpc('registrar_movimiento', params: params);
  }
}
