import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/exchange_rate_service.dart';

final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  return ExchangeRateService();
});

final tipoCambioProvider = FutureProvider<TipoCambioUsdBob>((ref) async {
  final service = ref.read(exchangeRateServiceProvider);
  return service.obtenerUsdBob();
});