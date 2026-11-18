import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/async_x.dart';
import '../../core/utils/validators.dart';
import '../../data/models/negocio.dart';
import '../../providers/negocio_provider.dart';
import '../../shared/form_fields.dart';
import '../../shared/widgets.dart';

/// HU-02: configuración del negocio (nombre, tipo y moneda).
/// La primera vez crea el negocio; después permite editarlo (desde Ajustes).
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  String? _tipo = 'tienda_barrio';
  bool _ocupado = false;
  late final bool _editando;

  @override
  void initState() {
    super.initState();
    final actual = ref.read(negocioProvider).dataOrNull;
    _editando = actual != null;
    if (actual != null) {
      _nombre.text = actual.nombre;
      _tipo = actual.tipo;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _ocupado = true);
    try {
      await ref.read(negocioProvider.notifier).guardar(nombre: _nombre.text, tipo: _tipo!);
      if (!mounted) return;
      showMessage(context, 'Negocio guardado.');
      context.go(Routes.home);
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: _editando,
        title: Text(_editando ? 'Editar negocio' : 'Configura tu negocio'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              _editando
                  ? 'Cambia los datos de tu negocio.'
                  : 'Cuéntanos de tu negocio. Te toma menos de un minuto.',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombre,
                    maxLength: 40,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => Validators.texto(
                      v,
                      vacio: 'El nombre del negocio es obligatorio.',
                      max: 40,
                      campo: 'el nombre',
                    ),
                    decoration: appInput(
                      label: 'Nombre del negocio',
                      helper: 'Así lo verás en la pantalla principal. Máximo 40 caracteres.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  PickerField<String>(
                    label: 'Tipo de negocio',
                    helper: 'Elige el que más se parezca al tuyo.',
                    value: _tipo,
                    items: [for (final e in Negocio.tipos.entries) PickerItem<String>(e.key, e.value)],
                    onChanged: (v) => setState(() => _tipo = v),
                    validator: (v) => v == null ? 'Elige un tipo de negocio.' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: 'Bolivianos (Bs)',
                    readOnly: true,
                    decoration: appInput(
                      label: 'Moneda',
                      helper: 'Por ahora todos los montos se manejan en bolivianos.',
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
                  : Text(_editando ? 'Guardar cambios' : 'Guardar y continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
