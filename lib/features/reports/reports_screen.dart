import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error.dart';
import '../../core/utils/format.dart';
import '../../data/analytics/resumen_financiero.dart';
import '../../providers/movimientos_provider.dart';
import '../../shared/state_views.dart';
import '../../shared/widgets.dart';

/// HU-11: cifras calculadas a partir de movimientos REALES, sin datos simulados.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  PeriodoReporte _periodo = PeriodoReporte.semana;

  @override
  Widget build(BuildContext context) {
    final mov = ref.watch(movimientosProvider);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes reales')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(movimientosProvider.notifier).cargar(silencioso: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 36),
            children: [
              SegmentedButton<PeriodoReporte>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: PeriodoReporte.dia, label: Text('Día')),
                  ButtonSegment(value: PeriodoReporte.semana, label: Text('Semana')),
                  ButtonSegment(value: PeriodoReporte.mes, label: Text('Mes')),
                ],
                selected: {_periodo},
                onSelectionChanged: (v) => setState(() => _periodo = v.first),
              ),
              const SizedBox(height: 12),
              mov.when(
                loading: () => const LoadingView(message: 'Consultando Supabase…'),
                error: (error, _) => ErrorView(message: friendlyError(error),
                    onRetry: () => ref.read(movimientosProvider.notifier).cargar()),
                data: (lista) {
                  final resumen = ResumenFinanciero.calcular(lista, periodo: _periodo);
                  final maxValue = resumen.barras.fold<double>(0, (m, n) => n > m ? n : m);
                  final masVendido = resumen.masVendidos.isEmpty
                      ? 0.0 : resumen.masVendidos.first.cantidad;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HeroCard(
                        label: 'Saldo neto del período', value: bs(resumen.saldo),
                        chip: '${resumen.cantidadOperaciones} movimientos activos · ventas − compras − gastos',
                        valueSize: 34,
                      ),
                      const SizedBox(height: 10),
                      AppCard(child: Column(children: [
                        _linea('Ventas', bs(resumen.ventas), scheme.primary),
                        _linea('Compras de inventario', bs(resumen.compras), scheme.secondary),
                        _linea('Otros gastos', bs(resumen.gastos), scheme.error),
                        const Divider(),
                        _linea('Total egresos', bs(resumen.egresos), scheme.error),
                      ])),
                      const SizedBox(height: 12),
                      Text('El saldo es un flujo neto de caja; no es utilidad contable. '
                          'No se dispone del costo de los productos vendidos.',
                          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                      const SectionTitle('Ventas en el período'),
                      AppCard(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ventas por ${switch (_periodo) {
                            PeriodoReporte.dia => 'intervalo horario',
                            PeriodoReporte.semana => 'día',
                            PeriodoReporte.mes => 'semana',
                          }}', style: text.titleSmall),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 145,
                            child: Row(crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                for (var i = 0; i < resumen.barras.length; i++)
                                  Expanded(child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Tooltip(
                                        message: '${resumen.etiquetas[i]}: ${bs(resumen.barras[i])}',
                                        child: Container(
                                          height: maxValue == 0 ? 2 : 110 * resumen.barras[i] / maxValue,
                                          margin: const EdgeInsets.symmetric(horizontal: 3),
                                          decoration: BoxDecoration(
                                            color: scheme.primary,
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      FittedBox(child: Text(resumen.etiquetas[i],
                                          style: text.bodySmall)),
                                    ],
                                  )),
                              ],
                            ),
                          ),
                        ],
                      )),
                      const SectionTitle('Productos más vendidos'),
                      if (resumen.masVendidos.isEmpty)
                        const AppCard(child: Text('No hay ventas activas en este período.'))
                      else
                        for (final item in resumen.masVendidos) ...[
                          AppCard(child: Column(children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Expanded(child: Text(item.nombre, style: const TextStyle(fontWeight: FontWeight.w600))),
                              Text('${qty(item.cantidad)} vendidos'),
                            ]),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(value: masVendido > 0 ? item.cantidad / masVendido : 0),
                          ])),
                          const SizedBox(height: 6),
                        ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linea(String etiqueta, String importe, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(etiqueta), Text(importe, style: TextStyle(color: color,
          fontWeight: FontWeight.w700))]),
  );
}
