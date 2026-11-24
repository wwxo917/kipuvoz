import 'dart:convert';
import 'package:http/http.dart' as http;

class TipoCambioUsdBob {
  const TipoCambioUsdBob({
    required this.tasaBob,
    required this.actualizadoTexto,
    required this.esRespaldo,
  });

  final double tasaBob;
  final String actualizadoTexto;
  final bool esRespaldo;

  double usdABob(double usd) => usd * tasaBob;
}

class ExchangeRateService {
  static const _url = 'https://open.er-api.com/v6/latest/USD';
  static const double _tasaRespaldo = 6.96;

  TipoCambioUsdBob? _cache;
  DateTime? _ultimoFetch;

  Future<TipoCambioUsdBob> obtenerUsdBob({bool forzar = false}) async {
    final ahora = DateTime.now();
    // Caché de 6 horas para respetar límites (el endpoint se actualiza cada 24 h)
    if (!forzar &&
        _cache != null &&
        _ultimoFetch != null &&
        ahora.difference(_ultimoFetch!) < const Duration(hours: 6)) {
      return _cache!;
    }

    try {
      final resp = await http
          .get(Uri.parse(_url))
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        if (data['result'] == 'success') {
          final rates = data['rates'] as Map<String, dynamic>;
          final bob = (rates['BOB'] as num?)?.toDouble();
          if (bob != null && bob > 0) {
            final fechaUtc = (data['time_last_update_utc'] as String?) ?? 'Hoy';
            _cache = TipoCambioUsdBob(
              tasaBob: bob,
              actualizadoTexto: fechaUtc,
              esRespaldo: false,
            );
            _ultimoFetch = ahora;
            return _cache!;
          }
        }
      }
    } catch (_) {
      // Si no hay internet o falla la API, devolvemos caché previo o tasa de respaldo
    }

    return _cache ??
        const TipoCambioUsdBob(
          tasaBob: _tasaRespaldo,
          actualizadoTexto: 'Referencia local',
          esRespaldo: true,
        );
  }
}