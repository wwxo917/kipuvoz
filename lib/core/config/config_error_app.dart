import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Se muestra cuando faltan las claves de Supabase, en vez de cerrar la app con un error.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, this.detail});

  final String? detail;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.settings_suggest_outlined, size: 48),
                const SizedBox(height: 16),
                const Text('Falta configurar Supabase',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                const Text(
                  '1. Copia env.example.json como env.json y escribe tu URL y tu clave pública de Supabase.\n\n'
                  '2. Ejecuta la app con:\n'
                  'flutter run --dart-define-from-file=env.json\n\n'
                  'En Android Studio: Run > Edit Configurations > Additional run args.',
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 16),
                  Text('Detalle: $detail', style: const TextStyle(fontSize: 14)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
