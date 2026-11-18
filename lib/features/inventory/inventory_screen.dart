import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/format.dart';
import '../../data/models/producto.dart';
import '../../providers/productos_provider.dart';
import '../../shared/state_views.dart';
import '../../shared/widgets.dart';

/// HU-07 / HU-08 / HU-09: inventario conectado a Supabase (READ), con alta (CREATE) y edición (UPDATE).
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _busqueda = '';
  int _filtro = 0; // 0 todos, 1 stock bajo, 2+ categorías

  List<Producto> _aplicarFiltros(List<Producto> todos) {
    return todos.where((p) {
      if (_busqueda.isNotEmpty && !p.nombre.toLowerCase().contains(_busqueda.toLowerCase())) return false;
      if (_filtro == 1) return p.stockBajo;
      if (_filtro >= 2) return p.categoria == Producto.categorias[_filtro - 2];
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final estado = ref.watch(productosProvider);
    final todos = estado.hasValue ? estado.requireValue : const <Producto>[];
    final bajos = todos.where((p) => p.stockBajo).length;
    final etiquetas = ['Todos', 'Stock bajo · $bajos', ...Producto.categorias];

    List<Widget> contenido() {
      return estado.when<List<Widget>>(
        loading: () => const [LoadingView(message: 'Cargando productos…')],
        error: (e, _) => [
          ErrorView(message: friendlyError(e), onRetry: () => ref.read(productosProvider.notifier).cargar()),
        ],
        data: (lista) {
          if (lista.isEmpty) {
            return [
              EmptyView(
                icon: Icons.inventory_2_outlined,
                title: 'Aún no tienes productos',
                message: 'Toca + para agregar uno.',
                actionLabel: 'Agregar producto',
                onAction: () => context.push(Routes.productNew),
              ),
            ];
          }
          final visibles = _aplicarFiltros(lista);
          if (visibles.isEmpty) {
            return const [
              EmptyView(
                icon: Icons.search_off,
                title: 'Sin resultados',
                message: 'No hay productos con esos filtros.',
              ),
            ];
          }
          return [for (final p in visibles) _ProductCard(producto: p)];
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar producto',
        onPressed: () => context.push(Routes.productNew),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(productosProvider.notifier).cargar(silencioso: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 96),
            children: [
              TextField(
                onChanged: (v) => setState(() => _busqueda = v.trim()),
                textInputAction: TextInputAction.search,
                decoration: appInput(
                  hint: 'Buscar producto',
                  prefix: Icon(Icons.search, color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 12),
              ChipFilterRow(labels: etiquetas, selected: _filtro, onSelected: (i) => setState(() => _filtro = i)),
              const SizedBox(height: 12),
              ...contenido(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.producto});

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final bajo = producto.stockBajo;
    final nivel = producto.stockMinimo <= 0
        ? (producto.stock > 0 ? 1.0 : 0.0)
        : (producto.stock / (producto.stockMinimo * 4)).clamp(0.0, 1.0);
    final subtitulo = bajo
        ? 'Stock bajo · mínimo ${qty(producto.stockMinimo)} ${producto.unidadPara(producto.stockMinimo)}'
        : producto.precioLabel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => context.push(Routes.productEdit(producto.id)),
        child: Column(
          children: [
            Row(
              children: [
                IconBadge(
                  icon: Icons.shopping_bag_outlined,
                  color: bajo ? scheme.error : scheme.secondary,
                  iconColor: bajo ? scheme.error : scheme.onSurface,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(producto.nombre, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        subtitulo,
                        style: text.bodySmall?.copyWith(color: bajo ? scheme.error : scheme.onSurfaceVariant),
                      ),
                      if (producto.categoria != null)
                        Text(producto.categoria!, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  producto.stockLabel,
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: bajo ? scheme.error : scheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: nivel,
                minHeight: 6,
                backgroundColor: scheme.outline,
                color: bajo ? scheme.error : scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
