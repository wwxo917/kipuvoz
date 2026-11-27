import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movimiento.dart';

class MovimientoRepository {
  MovimientoRepository(this._db);
  final SupabaseClient _db;

  /// Recupera todas las páginas (200 por consulta) para no falsear los reportes.
  Future<List<Movimiento>> listar() async {
    final resultados = <Movimiento>[];
    const pagina = 200;
    var desde = 0;
    while (true) {
      final data = await _db.from('movimientos')
          .select('*, movimiento_items(producto_id, cantidad, precio_unitario, productos(nombre))')
          .order('fecha', ascending: false)
          .order('id', ascending: false)
          .range(desde, desde + pagina - 1);
      resultados.addAll(data.map(Movimiento.fromMap));
      if (data.length < pagina) break;
      desde += pagina;
    }
    return resultados;
  }

  Future<void> registrar({
    required TipoMovimiento tipo,
    List<LineaMovimiento> lineas = const [],
    String? concepto,
    double? total,
    String origen = 'manual',
    String? textoOriginal,
  }) async {
    final params = <String, dynamic>{
      'p_tipo': tipo.name,
      'p_origen': origen,
      if (textoOriginal != null) 'p_texto_original': textoOriginal,
    };
    if (tipo == TipoMovimiento.gasto) {
      params['p_concepto'] = concepto?.trim();
      params['p_total'] = total;
    } else {
      params['p_items'] = lineas.map((l) => l.toMap()).toList();
    }
    await _db.rpc('registrar_movimiento', params: params);
  }

  /// Solo la función SQL puede anular y revertir stock de forma transaccional.
  Future<void> anular(String id, {String? motivo}) async {
    await _db.rpc('anular_movimiento', params: {
      'p_movimiento_id': id,
      'p_motivo': motivo?.trim() ?? 'Anulación solicitada por el comerciante',
    });
  }

  Future<void> corregir(Movimiento movimiento, {
    required List<LineaMovimiento> lineas,
    String? concepto,
    double? total,
    String? motivo,
  }) async {
    await _db.rpc('corregir_movimiento', params: {
      'p_movimiento_id': movimiento.id,
      'p_items': lineas.map((l) => l.toMap()).toList(),
      'p_concepto': concepto?.trim(),
      'p_total': total,
      'p_motivo': motivo ?? 'Corrección del registro',
    });
  }
}
