import '../models/movimiento.dart';

/// No hay costo unitario de mercancía vendida en el esquema actual.
/// Por ello se informa SALDO = ventas - compras - gastos, nunca utilidad contable.
enum PeriodoReporte { dia, semana, mes }

class ProductoVendido {
  const ProductoVendido(this.nombre, this.cantidad);
  final String nombre;
  final double cantidad;
}

class ResumenFinanciero {
  const ResumenFinanciero({
    required this.ventas,
    required this.compras,
    required this.gastos,
    required this.etiquetas,
    required this.barras,
    required this.masVendidos,
    required this.cantidadOperaciones,
  });
  final double ventas;
  final double compras;
  final double gastos;
  final List<String> etiquetas;
  final List<double> barras;
  final List<ProductoVendido> masVendidos;
  final int cantidadOperaciones;
  double get saldo => ventas - compras - gastos;
  double get egresos => compras + gastos;

  static ResumenFinanciero calcular(List<Movimiento> movimientos,
      {PeriodoReporte periodo = PeriodoReporte.dia, DateTime? referencia}) {
    final now = referencia ?? DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    final inicio = switch (periodo) {
      PeriodoReporte.dia => hoy,
      PeriodoReporte.semana => hoy.subtract(Duration(days: hoy.weekday - 1)),
      PeriodoReporte.mes => DateTime(now.year, now.month),
    };
    final fin = switch (periodo) {
      PeriodoReporte.dia => hoy.add(const Duration(days: 1)),
      PeriodoReporte.semana => inicio.add(const Duration(days: 7)),
      PeriodoReporte.mes => DateTime(now.year, now.month + 1),
    };
    final labels = switch (periodo) {
      PeriodoReporte.dia => const ['0-4h','4-8h','8-12h','12-16h','16-20h','20-24h'],
      PeriodoReporte.semana => const ['L','M','M','J','V','S','D'],
      PeriodoReporte.mes => const ['S1','S2','S3','S4','S5'],
    };
    final barras = List<double>.filled(labels.length, 0);
    final vendidos = <String, double>{};
    double ventas = 0, compras = 0, gastos = 0;
    var operaciones = 0;
    for (final m in movimientos) {
      if (m.anulado || m.fecha.isBefore(inicio) || !m.fecha.isBefore(fin)) continue;
      operaciones++;
      switch (m.tipo) {
        case TipoMovimiento.venta:
          ventas += m.total;
          final indice = switch (periodo) {
            PeriodoReporte.dia => m.fecha.hour ~/ 4,
            PeriodoReporte.semana => m.fecha.weekday - 1,
            PeriodoReporte.mes => (m.fecha.day - 1) ~/ 7,
          };
          barras[indice] += m.total;
          for (final item in m.items) {
            vendidos.update(item.nombre, (v) => v + item.cantidad,
                ifAbsent: () => item.cantidad);
          }
          break;
        case TipoMovimiento.compra:
          compras += m.total;
          break;
        case TipoMovimiento.gasto:
          gastos += m.total;
          break;
      }
    }
    final top = vendidos.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
    return ResumenFinanciero(
      ventas: ventas, compras: compras, gastos: gastos,
      etiquetas: labels, barras: barras,
      masVendidos: top.take(5).map((e) => ProductoVendido(e.key,e.value)).toList(),
      cantidadOperaciones: operaciones,
    );
  }
}
