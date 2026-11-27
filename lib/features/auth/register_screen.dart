import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/validators.dart';
import '../../providers/supabase_providers.dart';
import '../../shared/form_fields.dart';
import '../../shared/widgets.dart';

/// HU-12: registro de usuarios con correo y contraseña (Supabase Auth).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  final _confirmar = TextEditingController();
  bool _ocupado = false;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _ocupado = true);
    try {
      final sesionIniciada =
          await ref.read(authRepositoryProvider).registrar(_correo.text.trim(), _contrasena.text);
      if (!mounted) return;
      if (sesionIniciada) {
        showMessage(context, 'Cuenta creada. Ahora configura tu negocio.');
        // El router lleva a Configurar negocio.
      } else {
        showMessage(context, 'Cuenta creada. Revisa tu correo para confirmarla e inicia sesión.');
        context.go(Routes.login);
      }
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
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.login),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text('Crea tu cuenta', style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'Con tu cuenta tus datos quedan guardados en la nube y solo tú puedes verlos.',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: _correo,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    validator: Validators.correo,
                    decoration: appInput(label: 'Correo electrónico'),
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _contrasena,
                    label: 'Contraseña',
                    helper: 'Mínimo 6 caracteres.',
                    action: TextInputAction.next,
                    validator: Validators.contrasena,
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _confirmar,
                    label: 'Confirmar contraseña',
                    action: TextInputAction.done,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Confirma tu contraseña.';
                      if (v != _contrasena.text) return 'Las contraseñas no coinciden.';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _ocupado ? null : _registrar,
              child: _ocupado
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))
                  : const Text('Crear cuenta'),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => context.go(Routes.login),
                child: const Text('¿Ya tienes cuenta? Iniciar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
