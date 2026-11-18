
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_preview_plus/device_preview_plus.dart';

import 'core/config/config_error_app.dart';
import 'core/config/env.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verificar la configuración de Supabase.
  if (!Env.isConfigured) {
    runApp(const ConfigErrorApp());
    return;
  }

  // Inicializar Supabase.
  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  } catch (e) {
    runApp(ConfigErrorApp(detail: e.toString()));
    return;
  }

  // Iniciar KipuVoz con el simulador de dispositivos.
  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (context) => const ProviderScope(
        child: KipuVozApp(),
      ),
    ),
  );
}

class KipuVozApp extends ConsumerWidget {
  const KipuVozApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'KipuVoz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      // Configuración de Device Preview Plus.
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      // Sistema de navegación original.
      routerConfig: router,
    );
  }
}
