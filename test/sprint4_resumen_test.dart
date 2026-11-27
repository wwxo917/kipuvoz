import 'package:flutter_test/flutter_test.dart';
import 'package:kipuvoz/data/analytics/resumen_financiero.dart';
import 'package:kipuvoz/data/models/movimiento.dart';
import 'package:kipuvoz/data/models/producto.dart';
import 'package:kipuvoz/data/services/consulta_voz_service.dart';

Movimiento movimiento(String id, TipoMovimiento tipo, double total,
    {bool anulado = false, List<MovimientoItem> items = const []}) => Movimiento(
  id: id, tipo: tipo, detalle: 'prueba', total: total,
  estado: anulado ? 'anulado' : 'activo', origen: 'manual',
  fecha: DateTime(2026, 11, 25, 11, 0), items: items,
);

void main() {
  final movimientos = [
    movimiento('1', TipoMovimiento.venta, 90, items: [
      const MovimientoItem(productoId: 'aceite', nombre: 'Aceite', cantidad: 5, precioUnitario: 18),
    ]),
    movimiento('2', TipoMovimiento.compra, 40),
    movimiento('3', TipoMovimiento.gasto, 10),
    movimiento('4', TipoMovimiento.venta, 500, anulado: true),
  ];
  test('calcula saldo con compras y gastos, excluye anulados', () {
    final r = ResumenFinanciero.calcular(movimientos,
        referencia: DateTime(2026, 11, 25, 12));
    expect(r.ventas, 90);
    expect(r.compras, 40);
    expect(r.gastos, 10);
    expect(r.saldo, 40);
    expect(r.cantidadOperaciones, 3);
    expect(r.masVendidos.single.cantidad, 5);
    expect(r.barras.fold<double>(0, (a, b) => a + b), 90);
  });
  test('no mezcla operaciones fuera del período', () {
    final r = ResumenFinanciero.calcular(movimientos,
      periodo: PeriodoReporte.semana, referencia: DateTime(2026, 12, 25));
    expect(r.ventas, 0);
    expect(r.saldo, 0);
  });
  test('consulta por voz usa valores reales, no ejemplos de interfaz', () {
    final productos = [
      const Producto(id: 'aceite', nombre: 'Aceite', unidad: 'litro',
          precioVenta: 18, stock: 23, stockMinimo: 3),
    ];
    final ventas = ConsultaVozService.responder('¿Cuánto vendí hoy?',
      movimientos: movimientos, productos: productos,
      fecha: DateTime(2026, 11, 25));
    final stock = ConsultaVozService.responder('¿Cuánto stock tengo de aceite?',
      movimientos: movimientos, productos: productos,
      fecha: DateTime(2026, 11, 25));
    expect(ventas, contains('Bs 90'));
    expect(stock, contains('23'));
  });
}
