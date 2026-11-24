import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/format.dart';
import '../../data/models/movimiento.dart';
import '../../providers/movimientos_provider.dart';
import '../../shared/state_views.dart';
import '../../shared/widgets.dart';

/// HU-05 (criterio 3) / HU-07: historial leído desde Supabase, agrupado por día.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int _filtro = 0;
  static const _etiquetas = ['Todo', 'Ventas', 'Compras', 'Gastos'];
  static const _tipos = <TipoMovimiento?>[null, TipoMovimiento.venta, TipoMovimiento.compra, TipoMovimiento.gasto];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final estado = ref.watch(movimientosProvider);
    final tipo = _tipos[_filtro];

    List<Widget> contenido() {
      return estado.when<List<Widget>>(
        loading: () => const [LoadingView(message: 'Cargando movimientos…')],
        error: (e, _) => [
          ErrorView(message: friendlyError(e), onRetry: () => ref.read(movimientosProvider.notifier).cargar()),
        ],
        data: (lista) {
          if (lista.isEmpty) {
            return [
              EmptyView(
                icon: Icons.receipt_long_outlined,
                title: 'Aún no tienes movimientos',
                message: 'Toca + para registrar una venta, una compra o un gasto.',
                actionLabel: 'Registrar movimiento',
                onAction: () => context.push(Routes.entry),
              ),
            ];
          }
          // Agrupar por día manteniendo el orden (más reciente primero)
          final grupos = <String, List<Movimiento>>{};
          for (final m in lista) {
            if (tipo == null || m.tipo == tipo) {
              grupos.putIfAbsent(dayTitle(m.fecha), () => <Movimiento>[]).add(m);
            }
          }
          if (grupos.isEmpty) {
            return const [
              EmptyView(
                icon: Icons.filter_alt_off_outlined,
                title: 'Sin movimientos de este tipo',
                message: 'Prueba con otro filtro.',
              ),
            ];
          }
          return [
            for (final entrada in grupos.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 6),
                child: Text(
                  entrada.key,
                  style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
                ),
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    for (var i = 0; i < entrada.value.length; i++) ...[
                      MovementTile(movimiento: entrada.value[i]),
                      if (i < entrada.value.length - 1) const Divider(),
                    ],
                  ],
                ),
              ),
            ],
          ];
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Registrar movimiento',
        onPressed: () => context.push(Routes.entry),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(movimientosProvider.notifier).cargar(silencioso: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 96),
            children: [
              ChipFilterRow(labels: _etiquetas, selected: _filtro, onSelected: (i) => setState(() => _filtro = i)),
              ...contenido(),
            ],
          ),
        ),
      ),
    );
  }
}
