import '../../core/utils/format.dart';

/// El nombre de cada valor coincide con el texto guardado en la columna tipo.
enum TipoMovimiento { venta, compra, gasto }

extension TipoMovimientoX on TipoMovimiento {
  String get etiqueta => switch (this) {
        TipoMovimiento.venta => 'Venta',
        TipoMovimiento.compra => 'Compra',
        TipoMovimiento.gasto => 'Gasto',
      };

  String get guardado => switch (this) {
        TipoMovimiento.venta => 'Venta guardada',
        TipoMovimiento.compra => 'Compra guardada',
        TipoMovimiento.gasto => 'Gasto guardado',
      };
}

class Movimiento {
  const Movimiento({
    required this.id,
    required this.tipo,
    required this.detalle,
    required this.total,
    required this.estado,
    required this.origen,
    required this.fecha,
  });

  final String id;
  final TipoMovimiento tipo;
  final String detalle; // productos o concepto
  final double total;
  final String estado;
  final String origen;
  final DateTime fecha;

  bool get anulado => estado == 'anulado';

  factory Movimiento.fromMap(Map<String, dynamic> m) {
    final tipo = TipoMovimiento.values.byName(m['tipo'] as String);
    final rawItems = (m['movimiento_items'] as List<dynamic>?) ?? const <dynamic>[];
    final items = rawItems.map((e) {
      final item = e as Map<String, dynamic>;
      final producto = item['productos'] as Map<String, dynamic>?;
      final nombre = (producto?['nombre'] as String?) ?? 'Producto';
      return '$nombre ×${qty(item['cantidad'] as num)}';
    }).toList();
    final concepto = m['concepto'] as String?;

    String detalle;
    if (tipo == TipoMovimiento.gasto) {
      detalle = (concepto == null || concepto.trim().isEmpty) ? 'Gasto' : concepto;
    } else {
      detalle = items.isEmpty ? tipo.etiqueta : items.join(', ');
    }

    return Movimiento(
      id: m['id'] as String,
      tipo: tipo,
      detalle: detalle,
      total: (m['total'] as num).toDouble(),
      estado: (m['estado'] as String?) ?? 'activo',
      origen: (m['origen'] as String?) ?? 'manual',
      fecha: DateTime.parse(m['fecha'] as String).toLocal(),
    );
  }
}

/// Una línea (producto, cantidad y precio) de una venta o compra.
class LineaMovimiento {
  const LineaMovimiento({required this.productoId, required this.cantidad, required this.precioUnitario});

  final String productoId;
  final double cantidad;
  final double precioUnitario;

  Map<String, dynamic> toMap() => {
        'producto_id': productoId,
        'cantidad': cantidad,
        'precio_unitario': precioUnitario,
      };
}
