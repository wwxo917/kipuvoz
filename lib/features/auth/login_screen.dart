import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/validators.dart';
import '../../providers/supabase_providers.dart';
import '../../shared/form_fields.dart';
import '../../shared/widgets.dart';

/// HU-12: inicio de sesión con correo y contraseña (Supabase Auth).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _ocupado = false;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _ocupado = true);
    try {
      await ref.read(authRepositoryProvider).iniciarSesion(_correo.text.trim(), _contrasena.text);
      // El router detecta la sesión y lleva a Inicio (o a Configurar negocio si es la primera vez).
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
          onPressed: () => context.go(Routes.welcome),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text('Inicia sesión', style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'Usa tu correo y tu contraseña para ver tu negocio en cualquier teléfono.',
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
                    action: TextInputAction.done,
                    validator: (v) => Validators.requerido(v, 'Ingresa tu contraseña.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _ocupado ? null : _entrar,
              child: _ocupado
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))
                  : const Text('Iniciar sesión'),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => context.go(Routes.register),
                child: const Text('¿No tienes cuenta? Crear cuenta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
