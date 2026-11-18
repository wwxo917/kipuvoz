import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/async_x.dart';
import '../../core/utils/format.dart';
import '../../providers/movimientos_provider.dart';
import '../../providers/negocio_provider.dart';
import '../../shared/state_views.dart';
import '../../shared/widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final negocio = ref.watch(negocioProvider).dataOrNull;
    final movimientos = ref.watch(movimientosProvider);

    // HU-02, criterio 3: el nombre del negocio aparece en el encabezado.
    final nombre = negocio?.nombre ?? 'Mi negocio';
    final inicial = nombre.isEmpty ? 'K' : nombre.substring(0, 1).toUpperCase();
    final hora = DateTime.now().hour;
    final saludo = hora < 12 ? 'Buenos días' : (hora < 19 ? 'Buenas tardes' : 'Buenas noches');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            // Encabezado
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(saludo, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                      Text(
                        nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Cuenta y negocio',
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.push(Routes.settings),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      child: Text(inicial, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // FB-05: la ganancia es lo primero que se ve y con letra más grande.
            HeroCard(label: 'Ganancia de hoy', value: bs(320), chip: '↑ 12 % que ayer', valueSize: 44),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: StatCard(icon: Icons.north_east, color: scheme.primary, label: 'Ventas', value: bs(540))),
                const SizedBox(width: 12),
                Expanded(child: StatCard(icon: Icons.south_west, color: scheme.error, label: 'Gastos', value: bs(220))),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Resumen de ejemplo: se conectará a tus movimientos en el Sprint 3.',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),

            // Acción principal: dictar por voz
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  MicButton(onPressed: () => context.push(Routes.confirmation)),
                  const SizedBox(height: 36),
                  Text.rich(
                    TextSpan(
                      style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      children: const [
                        TextSpan(text: 'Toca y di: '),
                        TextSpan(text: '“Vendí 5 arroz a 40”', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(Routes.entry),
                    child: const Text('Registrar sin voz'),
                  ),
                ],
              ),
            ),

            // Últimos movimientos (desde Supabase)
            const SectionTitle('Últimos movimientos', top: 0),
            movimientos.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(
                message: friendlyError(e),
                onRetry: () => ref.read(movimientosProvider.notifier).cargar(),
              ),
              data: (lista) {
                if (lista.isEmpty) {
                  return const EmptyView(
                    icon: Icons.receipt_long_outlined,
                    title: 'Aún no tienes movimientos',
                    message: 'Registra tu primera venta con el micrófono o con “Registrar sin voz”.',
                  );
                }
                final recientes = lista.take(2).toList();
                return AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      for (var i = 0; i < recientes.length; i++) ...[
                        MovementTile(movimiento: recientes[i]),
                        if (i < recientes.length - 1) const Divider(),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
