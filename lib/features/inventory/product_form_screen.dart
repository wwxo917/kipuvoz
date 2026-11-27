import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import '../../core/utils/async_x.dart';
import '../../core/utils/format.dart';
import '../../core/utils/validators.dart';
import '../../data/models/producto.dart';
import '../../providers/productos_provider.dart';
import '../../shared/form_fields.dart';
import '../../shared/state_views.dart';
import '../../shared/widgets.dart';

/// HU-08: formulario para crear y editar un producto, y archivarlo (baja lógica).
/// Si productoId es null, crea; si no, edita.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productoId});

  final String? productoId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _precio = TextEditingController();
  final _stock = TextEditingController();
  final _stockMinimo = TextEditingController();
  String? _unidad = 'unidad';
  String? _categoria;
  Producto? _editando;
  bool _ocupado = false;
  bool _noEncontrado = false;

  @override
  void initState() {
    super.initState();
    final id = widget.productoId;
    if (id != null) {
      final lista = ref.read(productosProvider).dataOrNull ?? const <Producto>[];
      final encontrados = lista.where((p) => p.id == id).toList();
      if (encontrados.isEmpty) {
        _noEncontrado = true;
      } else {
        final p = encontrados.first;
        _editando = p;
        _nombre.text = p.nombre;
        _precio.text = qty(p.precioVenta);
        _stock.text = qty(p.stock);
        _stockMinimo.text = qty(p.stockMinimo);
        _unidad = p.unidad;
        _categoria = p.categoria;
      }
    } else {
      _stock.text = '0';
      _stockMinimo.text = '0';
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _stock.dispose();
    _stockMinimo.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _ocupado = true);
    try {
      final producto = Producto(
        id: _editando?.id ?? '',
        nombre: _nombre.text,
        unidad: _unidad!,
        precioVenta: Validators.parseNumero(_precio.text)!,
        stock: Validators.parseNumero(_stock.text)!,
        stockMinimo: Validators.parseNumero(_stockMinimo.text)!,
        categoria: _categoria,
      );
      final incluirCategoria = _categoria != null || _editando?.categoria != null;
      final notifier = ref.read(productosProvider.notifier);
      if (_editando == null) {
        await notifier.crear(producto, incluirCategoria: incluirCategoria);
      } else {
        await notifier.actualizar(_editando!.id, producto, incluirCategoria: incluirCategoria);
      }
      if (!mounted) return;
      showMessage(context, 'Producto guardado.');
      context.pop();
    } catch (e) {
      if (mounted) showMessage(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _archivar() async {
    final producto = _editando!;
    final ok = await confirmar(
      context,
      titulo: 'Archivar producto',
      mensaje: '“${producto.nombre}” dejará de aparecer en tu inventario, pero su historial se conserva. '
          'No se elimina.',
      accion: 'Archivar',
      peligro: true,
    );
    if (!ok || !mounted) return;
    setState(() => _ocupado = true);
    try {
      await ref.read(productosProvider.notifier).archivar(producto.id);
      if (!mounted) return;
      showMessage(context, 'Producto archivado.');
      context.pop();
    } catch (e) {
      if (mounted) showMessage(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = _editando != null;

    if (_noEncontrado) {
      return Scaffold(
        appBar: AppBar(title: const Text('Producto')),
        body: const Center(child: EmptyView(icon: Icons.search_off, title: 'Producto no encontrado', message: 'Vuelve al inventario y elige otro.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar producto' : 'Nuevo producto')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombre,
                    maxLength: 60,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.texto(
                      v,
                      vacio: 'El nombre es obligatorio.',
                      max: 60,
                      campo: 'el nombre',
                    ),
                    decoration: appInput(label: 'Nombre', helper: 'Cómo lo verás en tu lista. Ejemplo: Arroz.'),
                  ),
                  const SizedBox(height: 8),
                  PickerField<String>(
                    label: 'Unidad',
                    helper: 'En qué se mide o se vende.',
                    value: _unidad,
                    items: [for (final u in Producto.unidades) PickerItem<String>(u, u)],
                    onChanged: (v) => setState(() => _unidad = v),
                    validator: (v) => v == null ? 'Elige una unidad.' : null,
                  ),
                  const SizedBox(height: 20),
                  PickerField<String>(
                    label: 'Categoría (opcional)',
                    helper: 'Sirve para filtrar tu inventario.',
                    value: _categoria ?? '',
                    items: [
                      const PickerItem<String>('', 'Sin categoría'),
                      for (final c in Producto.categorias) PickerItem<String>(c, c),
                    ],
                    onChanged: (v) => setState(() => _categoria = (v == null || v.isEmpty) ? null : v),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _precio,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.decimal(v, campo: 'el precio'),
                    decoration: appInput(label: 'Precio de venta', prefixText: 'Bs ', helper: 'Lo que cobras por cada unidad.'),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _stock,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.decimal(v, campo: 'el stock'),
                    decoration: appInput(label: 'Stock actual', helper: 'Cantidad que tienes ahora.'),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _stockMinimo,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    validator: (v) => Validators.decimal(v, campo: 'el stock mínimo'),
                    decoration: appInput(
                      label: 'Stock mínimo',
                      helper: 'Te avisamos cuando el stock llegue a este número.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _ocupado ? null : _guardar,
              child: _ocupado
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))
                  : Text(editando ? 'Guardar cambios' : 'Guardar producto'),
            ),
            if (editando) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: _ocupado ? null : _archivar,
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Archivar producto'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
