import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Tipo de cambio obtenido de la API. No se inventa una cotización si la API falla.
class TipoCambioUsdBob {
  const TipoCambioUsdBob({
    required this.tasaBob,
    required this.actualizadoTexto,
    required this.esRespaldo,
  });
  final double tasaBob;
  final String actualizadoTexto;
  /// true significa tasa previamente guardada, NO una cotización actual.
  final bool esRespaldo;
  double usdABob(double usd) => usd * tasaBob;
}

class ExchangeRateService {
  ExchangeRateService({http.Client? client}) : _client = client ?? http.Client();
  static const String _url = 'https://open.er-api.com/v6/latest/USD';
  static const String _claveTasa = 'kv_tasa_bob_verificada';
  static const String _claveFecha = 'kv_tasa_bob_fecha_utc';
  final http.Client _client;
  TipoCambioUsdBob? _cache;
  DateTime? _ultimoFetch;

  Future<TipoCambioUsdBob> obtenerUsdBob({bool forzar = false}) async {
    final ahora = DateTime.now();
    if (!forzar && _cache != null && _ultimoFetch != null &&
        ahora.difference(_ultimoFetch!) < const Duration(hours: 6)) {
      // Si no se hizo otra solicitud, esta tasa proviene de caché y se identifica como tal.
      return TipoCambioUsdBob(
        tasaBob: _cache!.tasaBob,
        actualizadoTexto: _cache!.actualizadoTexto,
        esRespaldo: true,
      );
    }

    try {
      final resp = await _client.get(Uri.parse(_url)).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) throw const FormatException('Respuesta de API no disponible');
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      if (data['result'] != 'success') throw const FormatException('API sin resultado');
      final rates = data['rates'] as Map<String, dynamic>;
      final rate = (rates['BOB'] as num?)?.toDouble();
      if (rate == null || !rate.isFinite || rate <= 0) throw const FormatException('Tasa inválida');
      final lastUnix = data['time_last_update_unix'] as num?;
      final fecha = lastUnix == null
          ? (data['time_last_update_utc'] as String? ?? ahora.toUtc().toIso8601String())
          : DateTime.fromMillisecondsSinceEpoch(lastUnix.toInt() * 1000, isUtc: true).toIso8601String();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_claveTasa, rate);
      await prefs.setString(_claveFecha, fecha);
      _cache = TipoCambioUsdBob(tasaBob: rate, actualizadoTexto: fecha, esRespaldo: false);
      _ultimoFetch = ahora;
      return _cache!;
    } catch (_) {
      // Solo se permite una tasa real consultada anteriormente; nunca un número fijo.
      final prefs = await SharedPreferences.getInstance();
      final rate = prefs.getDouble(_claveTasa);
      final fecha = prefs.getString(_claveFecha);
      if (rate != null && fecha != null && rate > 0 && rate.isFinite) {
        _cache = TipoCambioUsdBob(tasaBob: rate, actualizadoTexto: fecha, esRespaldo: true);
        _ultimoFetch = ahora;
        return _cache!;
      }
      throw StateError('No hay tasa de cambio disponible. Conéctate a internet para convertir USD a Bs.');
    }
  }
}
