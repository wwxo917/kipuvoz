import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/movimiento.dart';
import 'auth_provider.dart';
import 'supabase_providers.dart';

/// Movimientos del negocio, del más reciente al más antiguo.
final movimientosProvider =
    NotifierProvider<MovimientosNotifier, AsyncValue<List<Movimiento>>>(MovimientosNotifier.new);

class MovimientosNotifier extends Notifier<AsyncValue<List<Movimiento>>> {
  bool _vivo = true;
  int _generacion = 0;

  @override
  AsyncValue<List<Movimiento>> build() {
    _vivo = true;
    _generacion++;
    ref.onDispose(() => _vivo = false);
    final userId = ref.watch(userIdProvider);
    if (userId == null) return const AsyncData<List<Movimiento>>(<Movimiento>[]);
    Future.microtask(() => cargar(silencioso: true));
    return const AsyncLoading<List<Movimiento>>();
  }

  Future<void> cargar({bool silencioso = false}) async {
    if (!_vivo) return;
    final generacion = _generacion;
    final usuario = ref.read(userIdProvider);
    if (usuario == null) return;
    if (!silencioso) state = const AsyncLoading<List<Movimiento>>();
    final result = await AsyncValue.guard(() => ref.read(movimientoRepositoryProvider).listar());
    if (_vivo && generacion == _generacion && ref.read(userIdProvider) == usuario) {
      state = result;
    }
  }

  /// Registra un movimiento y refresca el historial y el stock de los productos.
  Future<void> registrar({
    required TipoMovimiento tipo,
    List<LineaMovimiento> lineas = const [],
    String? concepto,
    double? total,
    String origen = 'manual',
    String? textoOriginal,
  }) async {
    await ref
        .read(movimientoRepositoryProvider)
        .registrar(tipo: tipo, lineas: lineas, concepto: concepto, total: total,
            origen: origen, textoOriginal: textoOriginal);
    await cargar(silencioso: true);
  }

  Future<void> anular(String id, {String? motivo}) async {
    await ref.read(movimientoRepositoryProvider).anular(id, motivo: motivo);
    await cargar(silencioso: true);
  }

  Future<void> corregir(Movimiento movimiento, {
    required List<LineaMovimiento> lineas,
    String? concepto,
    double? total,
    String? motivo,
  }) async {
    await ref.read(movimientoRepositoryProvider).corregir(movimiento,
        lineas: lineas, concepto: concepto, total: total, motivo: motivo);
    await cargar(silencioso: true);
  }

}
