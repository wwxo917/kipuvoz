import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/async_x.dart';
import '../../providers/auth_provider.dart';
import '../../providers/negocio_provider.dart';
import '../../providers/supabase_providers.dart';
import '../../shared/widgets.dart';

/// Cuenta y negocio: identifica al usuario autenticado, permite editar el negocio y cerrar sesión (HU-12).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _cerrarSesion(BuildContext context, WidgetRef ref) async {
    final ok = await confirmar(
      context,
      titulo: 'Cerrar sesión',
      mensaje: '¿Quieres cerrar sesión? Tus datos quedan guardados en la nube.',
      accion: 'Cerrar sesión',
      peligro: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(authRepositoryProvider).cerrarSesion();
      // El router detecta que no hay sesión y regresa a Bienvenida.
    } catch (e) {
      if (context.mounted) showMessage(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final negocio = ref.watch(negocioProvider).dataOrNull;
    final correo = ref.watch(sessionProvider)?.user.email ?? '';
    final nombre = negocio?.nombre ?? 'Mi negocio';
    final inicial = nombre.isEmpty ? 'K' : nombre.substring(0, 1).toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Cuenta y negocio')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    child: Text(inicial, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombre, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        Text(correo, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                        if (negocio != null)
                          Text('${negocio.tipoLabel} · ${negocio.moneda}',
                              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push(Routes.setup),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar negocio'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
              onPressed: () => _cerrarSesion(context, ref),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
