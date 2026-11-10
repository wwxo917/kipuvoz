import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/sample_data.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/format.dart';
import '../../shared/widgets.dart';

/// HU-04: maqueta de confirmación (datos de ejemplo; la IA llega en el Sprint 4).
/// Los botones Confirmar, Editar y Cancelar están fijos en la parte inferior,
/// por lo que siempre se ven sin hacer scroll (incluso en 360 × 640).
class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final total = sampleConfirmItems.fold<double>(0, (sum, item) => sum + item.subtotal);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirma tu registro')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                children: [
                  // Lo que la app escuchó
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Esto escuché', style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 2),
                        Text('“Vendí cinco arroz a cuarenta y dos aceites a dieciocho”', style: text.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(label: Text('Venta', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700))),
                      const Chip(label: Text('Entendí con 93 % de seguridad')),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Lo que la app entendió: producto, cantidad, precio unitario y subtotal
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      children: [
                        const _Cells('Producto', 'Cantidad', 'P. unit.', 'Subtotal', header: true),
                        const Divider(height: 16),
                        for (final item in sampleConfirmItems)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: _Cells(
                              item.product,
                              '${item.quantity} ${item.unit}',
                              bs(item.price),
                              bs(item.subtotal),
                            ),
                          ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            Text(bs(total),
                                style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Acciones fijas abajo
            Container(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(top: BorderSide(color: scheme.outline)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          content: Text('Venta guardada: ${bs(total)}'),
                          behavior: SnackBarBehavior.floating,
                        ));
                      context.go(Routes.home);
                    },
                    child: const Text('Confirmar y guardar'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => showSoon(context),
                          child: const Text('Editar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            foregroundColor: scheme.error,
                          ),
                          onPressed: () => context.go(Routes.home),
                          child: const Text('Cancelar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de 4 columnas: producto, cantidad, precio unitario y subtotal.
class _Cells extends StatelessWidget {
  const _Cells(this.product, this.quantity, this.price, this.subtotal, {this.header = false});

  final String product;
  final String quantity;
  final String price;
  final String subtotal;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final style = header
        ? text.labelMedium?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700)
        : text.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    Widget cell(String value, int flex, {bool right = false}) => Expanded(
          flex: flex,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: right ? TextAlign.right : TextAlign.left,
            style: style,
          ),
        );

    return Row(
      children: [
        cell(product, 5),
        cell(quantity, 5),
        cell(price, 4, right: true),
        cell(subtotal, 4, right: true),
      ],
    );
  }
}
