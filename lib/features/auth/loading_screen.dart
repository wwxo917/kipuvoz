import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error.dart';
import '../../providers/negocio_provider.dart';
import '../../shared/state_views.dart';

/// Pantalla intermedia mientras se carga el negocio del usuario (o error de conexión con Reintentar).
class LoadingScreen extends ConsumerWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final negocio = ref.watch(negocioProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: negocio.hasError && !negocio.hasValue
                ? ErrorView(
                    message: friendlyError(negocio.error!),
                    onRetry: () => ref.read(negocioProvider.notifier).cargar(),
                  )
                : const LoadingView(message: 'Cargando tu negocio…'),
          ),
        ),
      ),
    );
  }
}
