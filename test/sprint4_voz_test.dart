import 'package:flutter_test/flutter_test.dart';
import 'package:kipuvoz/data/models/movimiento.dart';
import 'package:kipuvoz/data/models/producto.dart';
import 'package:kipuvoz/data/services/exchange_rate_service.dart';
import 'package:kipuvoz/data/services/voice_command_service.dart';

class _CambioPrueba extends ExchangeRateService {
  @override
  Future<TipoCambioUsdBob> obtenerUsdBob({bool forzar = false}) async =>
      const TipoCambioUsdBob(tasaBob: 7, actualizadoTexto: '2026-11-25T00:00:00Z', esRespaldo: false);
}

void main() {
  final productos = [
    const Producto(id: 'p1', nombre: 'Aceite', unidad: 'litro',
        precioVenta: 18, stock: 20, stockMinimo: 2),
    const Producto(id: 'p2', nombre: 'Azúcar', unidad: 'kg',
        precioVenta: 6, stock: 50, stockMinimo: 5),
  ];
  final servicio = VoiceCommandService();
  test('venta local con producto cantidad y precio', () async {
    final v = await servicio.interpretar(texto: 'Vendí 5 litros de aceite a 18',
        productos: productos, exchangeService: _CambioPrueba());
    expect(v.tipo, TipoMovimiento.venta);
    expect(v.lineas.single.productoId, 'p1');
    expect(v.lineas.single.cantidad, 5);
    expect(v.totalBs, 90);
  });
  test('compra en dólares aplica tasa comprobada', () async {
    final v = await servicio.interpretar(texto: 'Compré 2 azúcar a 3 dólares',
        productos: productos, exchangeService: _CambioPrueba());
    expect(v.tipo, TipoMovimiento.compra);
    expect(v.enDolares, isTrue);
    expect(v.totalUsd, 6);
    expect(v.totalBs, 42);
  });
  test('rechaza texto ambiguo y no inventa operaciones', () async {
    expect(() => servicio.interpretar(texto: 'aceite', productos: productos,
        exchangeService: _CambioPrueba()), throwsFormatException);
    expect(() => servicio.interpretar(texto: 'Compré azúcar', productos: productos,
        exchangeService: _CambioPrueba()), throwsFormatException);
  });
}
