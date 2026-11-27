import 'package:speech_to_text/speech_to_text.dart';
import '../models/movimiento.dart';
import '../models/producto.dart';
import 'ai_command_service.dart';
import 'exchange_rate_service.dart';

class BorradorComandoVoz {
  const BorradorComandoVoz({
    required this.transcripcion,
    required this.tipo,
    required this.lineas,
    required this.enDolares,
    required this.tasaUsada,
    this.tasaFecha = '',
    this.tasaEsRespaldo = false,
    this.precioUnitarioUsd,
    this.aviso,
    this.interpretadoConIA = false,
  });
  final String transcripcion;
  final TipoMovimiento tipo;
  final List<LineaMovimiento> lineas;
  final bool enDolares;
  final double tasaUsada;
  final String tasaFecha;
  final bool tasaEsRespaldo;
  final double? precioUnitarioUsd;
  final String? aviso;
  final bool interpretadoConIA;

  double get totalBs => lineas.fold<double>(0, (acc, linea) => acc + linea.cantidad * linea.precioUnitario);
  double? get totalUsd => precioUnitarioUsd == null || lineas.isEmpty
      ? null : precioUnitarioUsd! * lineas.first.cantidad;
}

class VoiceCommandService {
  VoiceCommandService({this.aiService});
  final AiCommandService? aiService;
  final SpeechToText _stt = SpeechToText();

  Future<bool> inicializar() => _stt.initialize();

  Future<void> escuchar({
    required void Function(String texto, bool finalResult) onResultado,
    String localeId = 'es_BO',
  }) async {
    if (!await _stt.initialize()) {
      throw StateError('El reconocimiento de voz no está disponible en este dispositivo.');
    }
    String elegido = localeId;
    try {
      final locales = await _stt.locales();
      for (final loc in locales) {
        if (loc.localeId.toLowerCase().startsWith('es')) {
          elegido = loc.localeId;
          if (loc.localeId.toLowerCase().contains('bo')) break;
        }
      }
    } catch (_) { /* Respaldo con el idioma solicitado. */ }
    await _stt.listen(
      localeId: elegido,
      onResult: (res) => onResultado(res.recognizedWords, res.finalResult),
    );
  }

  Future<void> detener() => _stt.stop();

  static String normalizar(String s) => s.toLowerCase().trim()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll('ñ', 'n');

  static const Map<String, int> _numerosPalabras = {
    'un': 1, 'uno': 1, 'una': 1, 'dos': 2, 'tres': 3, 'cuatro': 4,
    'cinco': 5, 'seis': 6, 'siete': 7, 'ocho': 8, 'nueve': 9,
    'diez': 10, 'once': 11, 'doce': 12, 'trece': 13, 'catorce': 14,
    'quince': 15, 'dieciseis': 16, 'diecisiete': 17, 'dieciocho': 18,
    'diecinueve': 19, 'veinte': 20,
  };

  static List<double> _extraerNumeros(String texto) {
    final t = texto.replaceAllMapped(RegExp('\\b($_regexPalabras)\\b'),
        (match) => '${_numerosPalabras[match.group(0)]}');
    return RegExp(r'(?<!\w)\d+(?:[.,]\d+)?')
        .allMatches(t)
        .map((match) => double.tryParse(match.group(0)!.replaceAll(',', '.')))
        .whereType<double>().toList();
  }

  static const String _regexPalabras =
      'diecinueve|dieciocho|diecisiete|dieciseis|quince|catorce|trece|doce|once|veinte|diez|nueve|ocho|siete|seis|cinco|cuatro|tres|dos|uno|una|un';

  Producto? _buscarProducto(String texto, List<Producto> productos) {
    final ordenados = [...productos]..sort((a, b) => b.nombre.length.compareTo(a.nombre.length));
    for (final producto in ordenados) {
      final nombre = normalizar(producto.nombre);
      if (nombre.isEmpty) continue;
      if (RegExp('(^|\\W)${RegExp.escape(nombre)}(\\W|\$)').hasMatch(texto)) {
        return producto;
      }
    }
    return null;
  }

  Future<BorradorComandoVoz> interpretar({
    required String texto,
    required List<Producto> productos,
    required ExchangeRateService exchangeService,
  }) async {
    final frase = texto.trim();
    final t = normalizar(frase);
    if (frase.isEmpty) throw const FormatException('Di o escribe una instrucción.');

    final ai = await aiService?.interpretar(frase);
    var conIA = false;
    TipoMovimiento tipo;
    Producto? producto;
    double cantidad;
    double precio;
    bool enDolares;
    String? aviso;

    if (ai != null && (ai['tipo'] == 'venta' || ai['tipo'] == 'compra')) {
      tipo = TipoMovimiento.values.byName(ai['tipo'] as String);
      final id = ai['producto_id']?.toString();
      for (final p in productos) {
        if (p.id == id) producto = p;
      }
      final rawCantidad = ai['cantidad'];
      final rawPrecio = ai['precio_unitario'];
      cantidad = rawCantidad is num ? rawCantidad.toDouble() : -1;
      precio = rawPrecio is num ? rawPrecio.toDouble() : -1;
      enDolares = ai['moneda'] == 'USD';
      if (producto != null && cantidad > 0 && precio > 0) {
        conIA = true;
      } else {
        aviso = 'La IA no completó el comando; se aplicaron reglas locales.';
      }
    } else {
      aviso = 'Interpretación local: la IA requiere desplegar y configurar la función de Supabase.';
      tipo = TipoMovimiento.venta;
      cantidad = -1;
      precio = -1;
      enDolares = false;
    }

    if (!conIA) {
      final esCompra = RegExp(r'\b(compre|compramos|comprar|compra|abasteci|adquiri)\b').hasMatch(t);
      final esVenta = RegExp(r'\b(vendi|vendimos|vender|venta|vendio)\b').hasMatch(t);
      if (esCompra == esVenta) {
        throw const FormatException('Indica si es una venta o compra: por ejemplo, "Vendí 5 arroz a 40".');
      }
      tipo = esCompra ? TipoMovimiento.compra : TipoMovimiento.venta;
      producto = _buscarProducto(t, productos);
      if (producto == null) throw const FormatException('No encontré el producto en el inventario.');
      final numeros = _extraerNumeros(t);
      if (numeros.isEmpty) throw const FormatException('Indica la cantidad del producto.');
      cantidad = numeros.first;
      if (numeros.length < 2 && tipo == TipoMovimiento.compra) {
        throw const FormatException('Indica el precio unitario de la compra.');
      }
      precio = numeros.length >= 2 ? numeros[1] : producto.precioVenta;
      enDolares = RegExp(r'\b(usd|dolar|dolares)\b').hasMatch(t);
      if (numeros.length < 2) {
        aviso = 'Se utilizó el precio del inventario: revísalo antes de guardar.';
      }
    }
    if (cantidad <= 0 || !cantidad.isFinite || precio <= 0 || !precio.isFinite) {
      throw const FormatException('La cantidad y el precio deben ser mayores a cero.');
    }
    if (producto == null) throw const FormatException('Debes indicar un producto existente.');

    var tasa = 1.0;
    var fechaTasa = '';
    var respaldo = false;
    if (enDolares) {
      final cambio = await exchangeService.obtenerUsdBob();
      tasa = cambio.tasaBob;
      fechaTasa = cambio.actualizadoTexto;
      respaldo = cambio.esRespaldo;
      if (respaldo) aviso = 'Tasa guardada (no actual): revisa la fecha antes de confirmar.';
    }
    final precioBs = double.parse((precio * tasa).toStringAsFixed(2));
    return BorradorComandoVoz(
      transcripcion: frase,
      tipo: tipo,
      lineas: [LineaMovimiento(productoId: producto.id, cantidad: cantidad, precioUnitario: precioBs)],
      enDolares: enDolares,
      tasaUsada: tasa,
      tasaFecha: fechaTasa,
      tasaEsRespaldo: respaldo,
      precioUnitarioUsd: enDolares ? precio : null,
      aviso: aviso,
      interpretadoConIA: conIA,
    );
  }
}
