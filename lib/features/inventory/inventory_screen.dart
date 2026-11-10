import 'package:flutter/material.dart';

import '../../core/data/sample_data.dart';
import '../../shared/widgets.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _filter = 0;
  static const _labels = ['Todos', 'Stock bajo'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final items = sampleProducts.where((p) => _filter == 0 || p.low).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar producto',
        onPressed: () => showSoon(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 96),
          children: [
            SearchBar(
              hintText: 'Buscar producto',
              leading: const Icon(Icons.search),
              constraints: const BoxConstraints(minHeight: 52),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(scheme.surface),
              side: WidgetStatePropertyAll(BorderSide(color: scheme.outline)),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
            const SizedBox(height: 12),
            ChipFilterRow(labels: _labels, selected: _filter, onSelected: (i) => setState(() => _filter = i)),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Text('No hay productos con stock bajo.',
                    textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ),
            for (final p in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ProductCard(product: p),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final low = product.low;
    final accentColor = low ? scheme.error : scheme.onSurface;

    return AppCard(
      onTap: () => showSoon(context),
      child: Column(
        children: [
          Row(
            children: [
              IconBadge(
                icon: Icons.shopping_bag_outlined,
                color: low ? scheme.error : scheme.secondary,
                iconColor: low ? scheme.error : scheme.onSurface,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      low ? product.note : product.price,
                      style: text.bodySmall?.copyWith(color: low ? scheme.error : scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(product.stock, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: accentColor)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: product.level,
              minHeight: 6,
              backgroundColor: scheme.outline,
              color: low ? scheme.error : scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
