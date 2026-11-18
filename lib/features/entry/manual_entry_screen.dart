import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/async_x.dart';
import '../../core/utils/format.dart';
import '../../core/utils/validators.dart';
import '../../data/models/movimiento.dart';
import '../../data/models/producto.dart';
import '../../providers/movimientos_provider.dart';
import '../../providers/productos_provider.dart';
import '../../shared/form_fields.dart';
import '../../shared/state_views.dart';
import '../../shared/widgets.dart';

/// Una línea del formulario: producto, cantidad y precio.
class _Linea {
  _Linea(VoidCallback alCambiar) {
    cantidad.addListener(alCambiar);
    precio.addListener(alCambiar);
  }

  String? productoId;
  final cantidad = TextEditingController();
  final precio = TextEditingController();

  void dispose() {
    cantidad.dispose();
    precio.dispose();
  }
}

/// HU-05: registro manual de una venta, compra o gasto.
/// Guarda en Supabase con la función registrar_movimiento (actualiza el stock en una transacción).
class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _form = GlobalKey<FormState>();
  final _concepto = TextEditingController();
  final _monto = TextEditingController();
  final List<_Linea> _lineas = [];
  TipoMovimiento _tipo = TipoMovimiento.venta;
  bool _ocupado = false;

  void _refrescar() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _lineas.add(_Linea(_refrescar));
    _monto.addListener(_refrescar);
  }

  @override
  void dispose() {
    _concepto.dispose();
    _monto.dispose();
    for (final l in _lineas) {
      l.dispose();
    }
    super.dispose();
  }

  /// Total automático: suma de cantidad × precio (o el monto, si es un gasto).
  double get _total {
    if (_tipo == TipoMovimiento.gasto) return Validators.parseNumero(_monto.text) ?? 0;
    var total = 0.0;
    for (final l in _lineas) {
      final c = Validators.parseNumero(l.cantidad.text);
      final p = Validators.parseNumero(l.precio.text);
      if (c != null && p != null) total += c * p;
    }
    return total;
  }

  Producto? _producto(List<Producto> lista, String? id) {
    for (final p in lista) {
      if (p.id == id) return p;
    }
    return null;
  }

  void _elegirProducto(_Linea linea, String? id, List<Producto> productos) {
    final producto = _producto(productos, id);
    // En ventas se sugiere el precio del producto (se puede cambiar).
    if (producto != null && _tipo == TipoMovimiento.venta && linea.precio.text.trim().isEmpty) {
      linea.precio.text = qty(producto.precioVenta);
    }
    setState(() => linea.productoId = id);
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _ocupado = true);
    try {
      final total = _total;
      final movimientos = ref.read(movimientosProvider.notifier);
      if (_tipo == TipoMovimiento.gasto) {
        await movimientos.registrar(tipo: _tipo, concepto: _concepto.text, total: total);
      } else {
        final lineas = [
          for (final l in _lineas)
            LineaMovimiento(
              productoId: l.productoId!,
              cantidad: Validators.parseNumero(l.cantidad.text)!,
              precioUnitario: Validators.parseNumero(l.precio.text)!,
            ),
        ];
        await movimientos.registrar(tipo: _tipo, lineas: lineas);
      }
      // El stock cambió: se vuelve a leer el inventario.
      await ref.read(productosProvider.notifier).cargar(silencioso: true);
      if (!mounted) return;
      showMessage(context, '${_tipo.guardado}: ${bs(total)}.');
      context.pop();
    } catch (e) {
      if (mounted) showMessage(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final estadoProductos = ref.watch(productosProvider);
    final productos = estadoProductos.dataOrNull ?? const <Producto>[];
    final esGasto = _tipo == TipoMovimiento.gasto;

    Widget formulario() {
      if (esGasto) {
        return Column(
          children: [
            TextFormField(
              controller: _concepto,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.texto(v, vacio: 'Describe el gasto.', max: 60, campo: 'el concepto'),
              decoration: appInput(label: 'Concepto', helper: 'Ejemplo: transporte, luz, bolsas.'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _monto,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              validator: (v) => Validators.decimal(v, campo: 'el monto', positivo: true),
              decoration: appInput(label: 'Monto', prefixText: 'Bs ', helper: 'Cuánto gastaste.'),
            ),
          ],
        );
      }

      if (estadoProductos.isLoading && !estadoProductos.hasValue) {
        return const LoadingView(message: 'Cargando productos…');
      }
      if (estadoProductos.hasError && !estadoProductos.hasValue) {
        return ErrorView(
          message: friendlyError(estadoProductos.error!),
          onRetry: () => ref.read(productosProvider.notifier).cargar(),
        );
      }
      if (productos.isEmpty) {
        return EmptyView(
          icon: Icons.inventory_2_outlined,
          title: 'Primero agrega productos',
          message: 'Para registrar ventas o compras necesitas tener productos en tu inventario.',
          actionLabel: 'Ir a Inventario',
          onAction: () => context.go(Routes.inventory),
        );
      }

      return Column(
        children: [
          for (var i = 0; i < _lineas.length; i++) _construirLinea(i, productos),
          OutlinedButton.icon(
            onPressed: () => setState(() => _lineas.add(_Linea(_refrescar))),
            icon: const Icon(Icons.add),
            label: const Text('Agregar otro producto'),
          ),
        ],
      );
    }

    final puedeGuardar = esGasto || productos.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo movimiento')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          children: [
            SegmentedButton<TipoMovimiento>(
              showSelectedIcon: false,
              segments: [
                for (final t in TipoMovimiento.values) ButtonSegment<TipoMovimiento>(value: t, label: Text(t.etiqueta)),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
            const SizedBox(height: 16),
            Form(key: _form, child: formulario()),
            if (puedeGuardar) ...[
              const SizedBox(height: 16),
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      bs(_total),
                      style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _ocupado ? null : _guardar,
                child: _ocupado
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))
                    : const Text('Guardar'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _construirLinea(int i, List<Producto> productos) {
    final linea = _lineas[i];
    final esVenta = _tipo == TipoMovimiento.venta;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _lineas.length > 1 ? 'Producto ${i + 1}' : 'Producto',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (_lineas.length > 1)
                  IconButton(
                    tooltip: 'Quitar producto',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      final quitada = _lineas[i];
                      setState(() => _lineas.removeAt(i));
                      // Se liberan los controladores después de que el campo salió de pantalla.
                      WidgetsBinding.instance.addPostFrameCallback((_) => quitada.dispose());
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            PickerField<String>(
              label: 'Producto',
              value: linea.productoId,
              items: [
                for (final p in productos) PickerItem<String>(p.id, '${p.nombre} · ${p.stockLabel}'),
              ],
              onChanged: (v) => _elegirProducto(linea, v, productos),
              validator: (v) => v == null ? 'Elige un producto.' : null,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: linea.cantidad,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      final base = Validators.decimal(v, campo: 'la cantidad', positivo: true);
                      if (base != null) return base;
                      if (esVenta) {
                        final producto = _producto(productos, linea.productoId);
                        final n = Validators.parseNumero(v)!;
                        if (producto != null && n > producto.stock) {
                          return 'Solo hay ${producto.stockLabel}.';
                        }
                      }
                      return null;
                    },
                    decoration: appInput(label: 'Cantidad'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: linea.precio,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    validator: (v) => Validators.decimal(v, campo: 'el precio', positivo: true),
                    decoration: appInput(label: 'Precio unit.', prefixText: 'Bs '),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
