import '../../core/utils/format.dart';
import '../analytics/resumen_financiero.dart';
import '../models/movimiento.dart';
import '../models/producto.dart';
import 'voice_command_service.dart';

/// Respuestas basadas en registros reales del usuario, no en cifras de muestra.
class ConsultaVozService {
  static String responder(String pregunta,
      {required List<Movimiento> movimientos, required List<Producto> productos,
       DateTime? fecha}) {
    final t = VoiceCommandService.normalizar(pregunta);
    final resumen = ResumenFinanciero.calcular(movimientos,
        periodo: PeriodoReporte.dia, referencia: fecha);
    if (t.contains('stock') || t.contains('existencia') || t.contains('cuanto tengo')) {
      for (final p in productos) {
        if (t.contains(VoiceCommandService.normalizar(p.nombre))) {
          return 'Tienes ${qty(p.stock)} ${p.unidadPara(p.stock)} de ${p.nombre}.';
        }
      }
      return 'Menciona el nombre del producto del que deseas conocer las existencias.';
    }
    if (t.contains('productos') && (t.contains('cuantos') || t.contains('inventario'))) {
      return 'Tienes ${productos.length} productos activos en tu inventario.';
    }
    if (t.contains('saldo') || t.contains('ganancia') || t.contains('gane')) {
      return 'Tu saldo neto de hoy es ${bs(resumen.saldo)}. '
          'Se calcula como ventas menos compras y gastos; no representa utilidad contable.';
    }
    if (t.contains('compra')) return 'Hoy registraste compras por ${bs(resumen.compras)}.';
    if (t.contains('gasto') || t.contains('gaste')) return 'Hoy registraste gastos por ${bs(resumen.gastos)}.';
    if (t.contains('venta') || t.contains('vendi') || t.contains('vendido')) {
      return 'Hoy registraste ventas por ${bs(resumen.ventas)}.';
    }
    return 'Puedes preguntar cuánto vendiste hoy, cuánto gastaste hoy, tu saldo neto '
        'o el stock de un producto, por ejemplo: cuánto stock tengo de arroz.';
  }
}
