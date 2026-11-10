import 'package:flutter/material.dart';

import '../../core/data/sample_data.dart';
import '../../shared/widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _filter = 0;
  static const _labels = ['Todo', 'Ventas', 'Compras', 'Gastos'];
  static const _types = <MovementType?>[null, MovementType.sale, MovementType.purchase, MovementType.expense];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final type = _types[_filter];

    // Agrupar por día manteniendo el orden
    final groups = <String, List<Movement>>{};
    for (final m in sampleMovements) {
      if (type == null || m.type == type) groups.putIfAbsent('${m.day} · ${m.date}', () => []).add(m);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Registrar movimiento',
        onPressed: () => showSoon(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 96),
          children: [
            ChipFilterRow(labels: _labels, selected: _filter, onSelected: (i) => setState(() => _filter = i)),
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Text('No hay movimientos de este tipo.',
                    textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ),
            for (final entry in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 6),
                child: Text(
                  entry.key,
                  style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
                ),
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    for (var i = 0; i < entry.value.length; i++) ...[
                      MovementTile(
                        movement: entry.value[i],
                        onTap: () => showSoon(context, 'Disponible en el Sprint 3'),
                      ),
                      if (i < entry.value.length - 1) const Divider(),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
