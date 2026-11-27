import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/async_x.dart';
import '../../core/utils/format.dart';
import '../../data/models/movimiento.dart';
import '../../data/models/producto.dart';
import '../../data/services/voice_command_service.dart';
import '../../providers/exchange_rate_provider.dart';
import '../../providers/movimientos_provider.dart';
import '../../providers/productos_provider.dart';
import '../../providers/voice_provider.dart';
import '../../shared/widgets.dart';

class ConfirmationScreen extends ConsumerStatefulWidget {
  const ConfirmationScreen({super.key, this.borradorInicial});

  final BorradorComandoVoz? borradorInicial;

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  BorradorComandoVoz? _borrador;
  bool _guardando = false;
  bool _recalculando = false;

  @override
  void initState() {
    super.initState();
    _borrador = widget.borradorInicial;
  }

  Future<void> _editarTexto() async {
    final textoActual = _borrador?.transcripcion ?? '';
    final controller = TextEditingController(text: textoActual);

    final nuevoTexto = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar comando de voz'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ej: Vendí 5 arroz a 40 o Compré 2 azúcar a 3 dólares',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Interpretar'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (nuevoTexto == null || nuevoTexto.isEmpty) return;

    setState(() => _recalculando = true);
    try {
      final productos = ref.read(productosProvider).dataOrNull ?? const <Producto>[];
      final vozService = ref.read(voiceCommandServiceProvider);
      final exchangeService = ref.read(exchangeRateServiceProvider);
      final actualizado = await vozService.interpretar(
        texto: nuevoTexto,
        productos: productos,
        exchangeService: exchangeService,
      );
      if (!mounted) return;
      setState(() => _borrador = actualizado);
    } catch (e) {
      if (mounted) showMessage(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _recalculando = false);
    }
  }

  Future<void> _confirmarYGuardar() async {
    final borrador = _borrador;
    if (borrador == null || borrador.lineas.isEmpty) {
      showMessage(
        context,
        'No se detectó un producto de tu inventario. Edita la frase o regístralo manual.',
        error: true,
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      await ref.read(movimientosProvider.notifier).registrar(
        tipo: borrador.tipo,
        lineas: borrador.lineas,
        origen: 'voz',
        textoOriginal: borrador.transcripcion,
      );
      await ref.read(productosProvider.notifier).cargar(silencioso: true);
      await ref.read(movimientosProvider.notifier).cargar(silencioso: true);
      if (!mounted) return;
      showMessage(context, '${borrador.tipo.guardado}: ${bs(borrador.totalBs)}.');
      context.go(Routes.home);
    } catch (e) {
      if (mounted) showMessage(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final productos = ref.watch(productosProvider).dataOrNull ?? const <Producto>[];
    final borrador = _borrador;

    String nombreProducto(String id) {
      for (final p in productos) {
        if (p.id == id) return p.nombre;
      }
      return 'Producto';
    }

    String unidadProducto(String id, double cantidad) {
      for (final p in productos) {
        if (p.id == id) return p.unidadPara(cantidad);
      }
      return 'ud';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Confirma tu registro')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                children: [
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
                        Text(
                          borrador != null && borrador.transcripcion.isNotEmpty
                              ? '“${borrador.transcripcion}”'
                              : 'Sin comando de voz capturado todavía.',
                          style: text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (borrador != null) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text(
                            borrador.tipo.etiqueta,
                            style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (borrador.enDolares)
                          Chip(
                            label: Text('Convertido USD→Bs (1 USD = ${borrador.tasaUsada.toStringAsFixed(2)} Bs)'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_recalculando)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (borrador == null || borrador.lineas.isEmpty)
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No pude asociar el comando a un producto registrado',
                            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Asegúrate de nombrar un producto existente en tu inventario (por ejemplo: arroz o azúcar) y una cantidad o precio. También puedes tocar "Editar" o "Registrar sin voz".',
                            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  else
                    AppCard(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: Column(
                        children: [
                          const _Cells('Producto', 'Cantidad', 'P. unit.', 'Subtotal', header: true),
                          const Divider(height: 16),
                          for (final item in borrador.lineas)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: _Cells(
                                nombreProducto(item.productoId),
                                '${qty(item.cantidad)} ${unidadProducto(item.productoId, item.cantidad)}',
                                bs(item.precioUnitario),
                                bs(item.cantidad * item.precioUnitario),
                              ),
                            ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              Text(
                                bs(borrador.totalBs),
                                style: text.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (borrador != null && borrador.aviso?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    AppCard(child: Row(children: [
                      Icon(Icons.info_outline, color: scheme.tertiary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(borrador.aviso!)),
                    ])),
                  ],
                  if (borrador?.enDolares == true) ...[
                    const SizedBox(height: 12),
                    AppCard(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Detalle de conversión USD → Bs',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('Precio original: USD ${borrador!.precioUnitarioUsd?.toStringAsFixed(2) ?? '—'}'),
                        Text('Importe original: USD ${borrador.totalUsd?.toStringAsFixed(2) ?? '—'}'),
                        Text('Tipo de cambio: 1 USD = ${borrador.tasaUsada.toStringAsFixed(4)} Bs'),
                        Text('Actualizada (UTC): ${borrador.tasaFecha}'),
                        Text(borrador.tasaEsRespaldo
                          ? 'TASA GUARDADA - verifica la vigencia antes de confirmar.'
                          : 'Tasa consultada de ExchangeRate-API.'),
                        Text('Importe convertido: ${bs(borrador.totalBs)}'),
                      ],
                    )),
                  ],
                ],
              ),
            ),
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
                    onPressed: (_guardando || borrador == null || borrador.lineas.isEmpty)
                        ? null
                        : _confirmarYGuardar,
                    child: _guardando
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))
                        : const Text('Confirmar y guardar'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _guardando ? null : _editarTexto,
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
                          onPressed: _guardando ? null : () => context.go(Routes.home),
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
        textAlign: right ? TextAlign.right : TextAlign.left,
        style: style,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cell(product, 5),
        cell(quantity, 5),
        cell(price, 4, right: true),
        cell(subtotal, 4, right: true),
      ],
    );
  }
}