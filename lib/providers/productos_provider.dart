import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/producto.dart';
import 'auth_provider.dart';
import 'supabase_providers.dart';

/// Productos activos del negocio: cargando, con datos o con error.
final productosProvider =
    NotifierProvider<ProductosNotifier, AsyncValue<List<Producto>>>(ProductosNotifier.new);

class ProductosNotifier extends Notifier<AsyncValue<List<Producto>>> {
  bool _vivo = true;
  int _generacion = 0;

  @override
  AsyncValue<List<Producto>> build() {
    _vivo = true;
    _generacion++;
    ref.onDispose(() => _vivo = false);
    final userId = ref.watch(userIdProvider);
    if (userId == null) return const AsyncData<List<Producto>>(<Producto>[]);
    Future.microtask(() => cargar(silencioso: true));
    return const AsyncLoading<List<Producto>>();
  }

  Future<void> cargar({bool silencioso = false}) async {
    if (!_vivo) return;
    final generacion = _generacion;
    final usuario = ref.read(userIdProvider);
    if (usuario == null) return;
    if (!silencioso) state = const AsyncLoading<List<Producto>>();
    final result = await AsyncValue.guard(() => ref.read(productoRepositoryProvider).listar());
    if (_vivo && generacion == _generacion && ref.read(userIdProvider) == usuario) {
      state = result;
    }
  }

  Future<void> crear(Producto p, {bool incluirCategoria = false}) async {
    await ref.read(productoRepositoryProvider).crear(p, incluirCategoria: incluirCategoria);
    await cargar(silencioso: true);
  }

  Future<void> actualizar(String id, Producto p, {bool incluirCategoria = false}) async {
    await ref.read(productoRepositoryProvider).actualizar(id, p, incluirCategoria: incluirCategoria);
    await cargar(silencioso: true);
  }

  Future<void> archivar(String id) async {
    await ref.read(productoRepositoryProvider).archivar(id);
    await cargar(silencioso: true);
  }
}
