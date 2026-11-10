import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/sample_data.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/format.dart';
import '../../shared/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

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
                      Text('Buenos días', style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                      Text('Tienda Doña Rosa', style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                // En el Sprint 3 el avatar abrirá Ajustes.
                Semantics(
                  button: true,
                  label: 'Ajustes y cuenta',
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => showSoon(context, 'Disponible en el Sprint 3'),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      child: const Text('DR', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Resumen del día
            HeroCard(label: 'Ganancia de hoy', value: bs(320), chip: '↑ 12 % que ayer'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: StatCard(icon: Icons.north_east, color: scheme.primary, label: 'Ventas', value: bs(540))),
                const SizedBox(width: 12),
                Expanded(child: StatCard(icon: Icons.south_west, color: scheme.error, label: 'Gastos', value: bs(220))),
              ],
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
                  TextButton(onPressed: () => showSoon(context), child: const Text('Registrar sin voz')),
                ],
              ),
            ),

            // Últimos movimientos
            const SectionTitle('Últimos movimientos', top: 0),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  MovementTile(movement: sampleMovements[0], onTap: () => showSoon(context, 'Disponible en el Sprint 3')),
                  const Divider(),
                  MovementTile(movement: sampleMovements[1], onTap: () => showSoon(context, 'Disponible en el Sprint 3')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
