import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/format.dart';
import '../../data/models/movimiento.dart';
import '../../providers/movimientos_provider.dart';
import '../../providers/productos_provider.dart';
import '../../shared/state_views.dart';
import '../../shared/widgets.dart';

/// HU-06 y HU-10: historial con fechas, detalle, corrección y anulación atómicas.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int _filtro = 0;
  DateTime? _desde;
  DateTime? _hasta;
  bool _verAnulados = true;
  static const _etiquetas = ['Todo', 'Ventas', 'Compras', 'Gastos'];
  static const _tipos = <TipoMovimiento?>[
    null, TipoMovimiento.venta, TipoMovimiento.compra, TipoMovimiento.gasto,
  ];

  Future<void> _elegirFecha({required bool desde}) async {
    final inicial = desde ? _desde : _hasta;
    final f = await showDatePicker(
      context: context,
      initialDate: inicial ?? DateTime.now(),
      firstDate: DateTime(2020), lastDate: DateTime(2100),
    );
    if (f == null || !mounted) return;
    setState(() { if (desde) { _desde = f; } else { _hasta = f; } });
  }

  Future<void> _anular(Movimiento m) async {
    final ok = await confirmar(context,
      titulo: 'Anular ${m.tipo.etiqueta.toLowerCase()}',
      mensaje: 'Se revertirá el stock de este movimiento si es posible. '
          'No se borrará la operación del historial. ¿Continuar?',
      accion: 'Anular movimiento', peligro: true);
    if (!ok || !mounted) return;
    try {
      await ref.read(movimientosProvider.notifier).anular(m.id,
          motivo: 'Anulado desde el historial de KipuVoz');
      await ref.read(productosProvider.notifier).cargar(silencioso: true);
      if (mounted) showMessage(context, 'Movimiento anulado. Stock actualizado.');
    } catch (e) {
      if (mounted) showMessage(context, friendlyError(e), error: true);
    }
  }

  Future<void> _mostrarDetalle(Movimiento m) async {
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (ctx) => SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
        child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${m.tipo.etiqueta} ${m.anulado ? 'ANULADA' : ''}',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${dateLabel(m.fecha)} a las ${timeLabel(m.fecha)} · ${m.origen}'),
            const SizedBox(height: 6),
            Text('Total: ${bs(m.total)}', style: Theme.of(ctx).textTheme.titleMedium),
            if (m.concepto?.isNotEmpty == true) Text('Concepto: ${m.concepto}'),
            if (m.textoOriginal?.isNotEmpty == true)
              Text('Texto original: ${m.textoOriginal}'),
            if (m.motivoAnulacion?.isNotEmpty == true)
              Text('Motivo de anulación: ${m.motivoAnulacion}'),
            if (m.reemplazaId != null)
              const Text('Este registro corrige un movimiento anterior.'),
            const Divider(height: 22),
            for (final i in m.items)
              Padding(padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text('${i.nombre} · ${qty(i.cantidad)} × ${bs(i.precioUnitario)} = ${bs(i.subtotal)}')),
            if (!m.anulado) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push(Routes.movementEdit, extra: m);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Corregir movimiento'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _anular(m);
                },
                icon: const Icon(Icons.block),
                label: const Text('Anular movimiento'),
                style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
              ),
            ],
          ],
        )),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final estado = ref.watch(movimientosProvider);
    final tipo = _tipos[_filtro];

    List<Widget> contenido() => estado.when<List<Widget>>(
      loading: () => const [LoadingView(message: 'Cargando movimientos…')],
      error: (e, _) => [ErrorView(message: friendlyError(e),
          onRetry: () => ref.read(movimientosProvider.notifier).cargar())],
      data: (lista) {
        if (lista.isEmpty) {
          return [EmptyView(icon: Icons.receipt_long_outlined,
              title: 'Aún no tienes movimientos',
              message: 'Toca + para registrar una venta, compra o gasto.',
              actionLabel: 'Registrar movimiento',
              onAction: () => context.push(Routes.entry))];
        }
        final filtrados = lista.where((m) =>
            (tipo == null || m.tipo == tipo) &&
            (_verAnulados || !m.anulado) &&
            (_desde == null || !m.fecha.isBefore(_desde!)) &&
            (_hasta == null || m.fecha.isBefore(_hasta!.add(const Duration(days: 1)))))
            .toList();
        if (filtrados.isEmpty) {
          return const [EmptyView(icon: Icons.filter_alt_off_outlined,
              title: 'No hay movimientos para esos filtros',
              message: 'Elige otras fechas o tipos de movimiento.')];
        }
        final grupos = <String, List<Movimiento>>{};
        for (final m in filtrados) {
          grupos.putIfAbsent(dayTitle(m.fecha), () => []).add(m);
        }
        return [
          for (final grupo in grupos.entries) ...[
            Padding(padding: const EdgeInsets.only(top: 16, bottom: 6),
              child: Text(grupo.key, style: text.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant))),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(children: [
                for (var i = 0; i < grupo.value.length; i++) ...[
                  MovementTile(movimiento: grupo.value[i],
                      onTap: () => _mostrarDetalle(grupo.value[i])),
                  if (i < grupo.value.length - 1) const Divider(),
                ],
              ]),
            ),
          ],
        ];
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Registrar movimiento',
        onPressed: () => context.push(Routes.entry), child: const Icon(Icons.add)),
      body: SafeArea(child: RefreshIndicator(
        onRefresh: () => ref.read(movimientosProvider.notifier).cargar(silencioso: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
          children: [
            ChipFilterRow(labels: _etiquetas, selected: _filtro,
                onSelected: (i) => setState(() => _filtro = i)),
            const SizedBox(height: 7),
            Wrap(spacing: 8, children: [
              ActionChip(label: Text(_desde == null ? 'Desde' : dateLabel(_desde!)),
                  avatar: const Icon(Icons.event, size: 16), onPressed: () => _elegirFecha(desde: true)),
              ActionChip(label: Text(_hasta == null ? 'Hasta' : dateLabel(_hasta!)),
                  avatar: const Icon(Icons.event, size: 16), onPressed: () => _elegirFecha(desde: false)),
              if (_desde != null || _hasta != null)
                ActionChip(label: const Text('Limpiar fechas'),
                    onPressed: () => setState(() { _desde = null; _hasta = null; })),
            ]),
            SwitchListTile.adaptive(
              dense: true, title: const Text('Mostrar anulados'),
              value: _verAnulados, onChanged: (v) => setState(() => _verAnulados = v)),
            ...contenido(),
          ],
        ),
      )),
    );
  }
}
