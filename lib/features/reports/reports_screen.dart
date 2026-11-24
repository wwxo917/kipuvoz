import 'package:flutter/material.dart';

import '../../core/utils/format.dart';
import '../../shared/widgets.dart';

class _Period {
  const _Period({
    required this.profit,
    required this.sales,
    required this.expenses,
    required this.title,
    required this.bars,
    required this.labels,
    required this.caption,
  });

  final double profit;
  final double sales;
  final double expenses;
  final String title;
  final List<double> bars;
  final List<String> labels;
  final String caption;
}

const _periods = <_Period>[
  _Period(
    profit: 320, sales: 540, expenses: 220,
    title: 'Ventas por hora', caption: 'de hoy',
    bars: [0.3, 0.6, 0.45, 0.9, 0.7, 0.4],
    labels: ['8h', '10h', '12h', '14h', '16h', '18h'],
  ),
  _Period(
    profit: 2090, sales: 3240, expenses: 1150,
    title: 'Ventas por día', caption: 'de la semana',
    bars: [0.5, 0.7, 0.45, 0.85, 1.0, 0.9, 0.4],
    labels: ['L', 'M', 'M', 'J', 'V', 'S', 'D'],
  ),
  _Period(
    profit: 8460, sales: 12900, expenses: 4440,
    title: 'Ventas por semana', caption: 'del mes',
    bars: [0.7, 0.85, 0.6, 1.0],
    labels: ['S1', 'S2', 'S3', 'S4'],
  ),
];

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _index = 1; // Semana

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final p = _periods[_index];

    var maxIndex = 0;
    for (var i = 1; i < p.bars.length; i++) {
      if (p.bars[i] > p.bars[maxIndex]) maxIndex = i;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          children: [
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 0, label: Text('Día')),
                ButtonSegment(value: 1, label: Text('Semana')),
                ButtonSegment(value: 2, label: Text('Mes')),
              ],
              selected: {_index},
              onSelectionChanged: (s) => setState(() => _index = s.first),
            ),
            const SizedBox(height: 8),
            Text(
              'Datos de ejemplo: los reportes se conectan a tus movimientos en el Sprint 3.',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            HeroCard(
              label: 'Ganancia ${p.caption}',
              value: bs(p.profit),
              chip: 'Ventas ${bs(p.sales)} · Gastos ${bs(p.expenses)}',
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Semantics(
                    label: '${p.title}. El valor más alto es ${p.labels[maxIndex]}.',
                    child: SizedBox(
                      height: 150,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var i = 0; i < p.bars.length; i++)
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 110 * p.bars[i],
                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      color: i == maxIndex ? scheme.primary : scheme.primaryContainer,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                        bottom: Radius.circular(3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(p.labels[i], style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SectionTitle('Más vendidos'),
            const _TopProduct(name: 'Arroz', amount: '48 bolsas', value: 0.9),
            const SizedBox(height: 10),
            const _TopProduct(name: 'Aceite', amount: '31 un.', value: 0.6),
          ],
        ),
      ),
    );
  }
}

class _TopProduct extends StatelessWidget {
  const _TopProduct({required this.name, required this.amount, required this.value});

  final String name;
  final String amount;
  final double value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text(amount, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: scheme.outline,
            color: scheme.primary,
          ),
        ),
      ],
    );
  }
}
