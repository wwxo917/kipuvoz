import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/negocio.dart';
import 'auth_provider.dart';
import 'supabase_providers.dart';

/// Negocio del usuario autenticado: cargando, con datos (o null si aún no lo configura) o con error.
final negocioProvider =
    NotifierProvider<NegocioNotifier, AsyncValue<Negocio?>>(NegocioNotifier.new);

class NegocioNotifier extends Notifier<AsyncValue<Negocio?>> {
  bool _vivo = true;
  int _generacion = 0;

  @override
  AsyncValue<Negocio?> build() {
    _vivo = true;
    _generacion++;
    ref.onDispose(() => _vivo = false);
    final userId = ref.watch(userIdProvider);
    if (userId == null) return const AsyncData<Negocio?>(null);
    Future.microtask(() => cargar(silencioso: true));
    return const AsyncLoading<Negocio?>();
  }

  Future<void> cargar({bool silencioso = false}) async {
    if (!_vivo) return;
    final generacion = _generacion;
    final usuario = ref.read(userIdProvider);
    if (usuario == null) return;
    if (!silencioso) state = const AsyncLoading<Negocio?>();
    final result = await AsyncValue.guard(() => ref.read(negocioRepositoryProvider).obtener());
    if (_vivo && generacion == _generacion && ref.read(userIdProvider) == usuario) {
      state = result;
    }
  }

  /// Crea el negocio la primera vez y lo actualiza después (HU-02).
  Future<void> guardar({required String nombre, required String tipo}) async {
    final repo = ref.read(negocioRepositoryProvider);
    final actual = state.hasValue ? state.requireValue : null;
    final usuario = ref.read(userIdProvider);
    final negocio = actual == null
        ? await repo.crear(nombre: nombre, tipo: tipo)
        : await repo.actualizar(actual.id, nombre: nombre, tipo: tipo);
    if (_vivo && ref.read(userIdProvider) == usuario) {
      state = AsyncData<Negocio?>(negocio);
    }
  }
}
