import 'package:speech_to_text/speech_to_text.dart';
import '../../data/models/movimiento.dart';
import '../../data/models/producto.dart';
import 'exchange_rate_service.dart';

class BorradorComandoVoz {
  const BorradorComandoVoz({
    required this.transcripcion,
    required this.tipo,
    required this.lineas,
    required this.enDolares,
    required this.tasaUsada,
  });

  final String transcripcion;
  final TipoMovimiento tipo;
  final List<LineaMovimiento> lineas;
  final bool enDolares;
  final double tasaUsada;

  double get totalBs => lineas.fold<double>(
    0,
        (acc, l) => acc + (l.cantidad * l.precioUnitario),
  );
}

class VoiceCommandService {
  final SpeechToText _stt = SpeechToText();

  Future<bool> inicializar() async {
    return _stt.initialize();
  }

  Future<void> escuchar({
    required void Function(String texto, bool finalResult) onResultado,
    String localeId = 'es_BO',
  }) async {
    final disponible = await _stt.initialize();
    if (!disponible) {
      throw Exception('El reconocimiento de voz no está disponible en este dispositivo.');
    }

    String? localeElegido;
    try {
      final locales = await _stt.locales();
      for (final loc in locales) {
        if (loc.localeId.toLowerCase().startsWith('es')) {
          localeElegido = loc.localeId;
          if (loc.localeId.toLowerCase().contains('bo')) break;
        }
      }
    } catch (_) {}

    await _stt.listen(
      listenOptions: SpeechListenOptions(
      localeId: localeElegido ?? localeId,
      ),
      onResult: (res) {
        onResultado(res.recognizedWords, res.finalResult);
      },
    );
  }

  Future<void> detener() async {
    await _stt.stop();
  }

  /// Convierte una frase dictada en un borrador de movimiento compatible con `registrar_movimiento`.
  /// Ejemplo: "Vendí 5 arroz a 40" o "Compré 2 azúcar a 10 dólares"
  Future<BorradorComandoVoz> interpretar({
    required String texto,
    required List<Producto> productos,
    required ExchangeRateService exchangeService,
  }) async {
    final limpio = texto.toLowerCase().trim();
    final tipo = (limpio.contains('compr') || limpio.contains('abastec'))
        ? TipoMovimiento.compra
        : TipoMovimiento.venta;

    final enDolares = limpio.contains('dolar') ||
        limpio.contains('dólar') ||
        limpio.contains('usd');

    final tipoCambio = enDolares
        ? await exchangeService.obtenerUsdBob()
        : const TipoCambioUsdBob(
      tasaBob: 1.0,
      actualizadoTexto: 'Moneda local (Bs)',
      esRespaldo: false,
    );

    final factor = enDolares ? tipoCambio.tasaBob : 1.0;

    // Extrae números (enteros o decimales con punto o coma) en orden de aparición
    final numeros = RegExp(r'\d+(?:[.,]\d+)?')
        .allMatches(limpio)
        .map((m) => double.tryParse(m.group(0)!.replaceAll(',', '.')))
        .whereType<double>()
        .toList();

    Producto? productoEncontrado;
    for (final p in productos) {
      final nombreLower = p.nombre.toLowerCase().trim();
      if (nombreLower.isNotEmpty && limpio.contains(nombreLower)) {
        productoEncontrado = p;
        break;
      }
    }

    final lineas = <LineaMovimiento>[];
    if (productoEncontrado != null) {
      final cantidad = numeros.isNotEmpty ? numeros[0] : 1.0;
      double precioUnitario;

      if (numeros.length >= 2) {
        precioUnitario = numeros[1] * factor;
      } else {
        precioUnitario = productoEncontrado.precioVenta;
      }

      lineas.add(
        LineaMovimiento(
          productoId: productoEncontrado.id,
          cantidad: cantidad,
          precioUnitario: double.parse(precioUnitario.toStringAsFixed(2)),
        ),
      );
    }

    return BorradorComandoVoz(
      transcripcion: texto.trim(),
      tipo: tipo,
      lineas: lineas,
      enDolares: enDolares,
      tasaUsada: tipoCambio.tasaBob,
    );
  }
}