import '../../core/utils/format.dart';

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

class MovimientoItem {
  const MovimientoItem({
    required this.productoId,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
  });

  final String productoId;
  final String nombre;
  final double cantidad;
  final double precioUnitario;
  double get subtotal => cantidad * precioUnitario;

  LineaMovimiento get linea => LineaMovimiento(
        productoId: productoId, cantidad: cantidad, precioUnitario: precioUnitario);

  factory MovimientoItem.fromMap(Map<String, dynamic> map) {
    final producto = map['productos'] as Map<String, dynamic>?;
    return MovimientoItem(
      productoId: map['producto_id'] as String,
      nombre: (producto?['nombre'] as String?) ?? 'Producto archivado',
      cantidad: (map['cantidad'] as num).toDouble(),
      precioUnitario: (map['precio_unitario'] as num).toDouble(),
    );
  }
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
    this.items = const [],
    this.concepto,
    this.textoOriginal,
    this.reemplazaId,
    this.motivoAnulacion,
  });

  final String id;
  final TipoMovimiento tipo;
  final String detalle;
  final double total;
  final String estado;
  final String origen;
  final DateTime fecha;
  final List<MovimientoItem> items;
  final String? concepto;
  final String? textoOriginal;
  final String? reemplazaId;
  final String? motivoAnulacion;

  bool get anulado => estado == 'anulado';

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    final tipo = TipoMovimiento.values.byName(map['tipo'] as String);
    final items = ((map['movimiento_items'] as List<dynamic>?) ?? const [])
        .map((e) => MovimientoItem.fromMap(e as Map<String, dynamic>)).toList();
    final concepto = map['concepto'] as String?;
    final detalle = tipo == TipoMovimiento.gasto
        ? (concepto?.trim().isNotEmpty == true ? concepto! : 'Gasto')
        : items.isEmpty ? tipo.etiqueta : items.map((i) => '${i.nombre} ×${qty(i.cantidad)}').join(', ');
    return Movimiento(
      id: map['id'] as String,
      tipo: tipo,
      detalle: detalle,
      total: (map['total'] as num).toDouble(),
      estado: (map['estado'] as String?) ?? 'activo',
      origen: (map['origen'] as String?) ?? 'manual',
      fecha: DateTime.parse(map['fecha'] as String).toLocal(),
      items: items,
      concepto: concepto,
      textoOriginal: map['texto_original'] as String?,
      reemplazaId: map['reemplaza_id'] as String?,
      motivoAnulacion: map['motivo_anulacion'] as String?,
    );
  }
}

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
