import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipuvoz/core/config/config_error_app.dart';

void main() {
  testWidgets('sin credenciales se indican instrucciones claras', (tester) async {
    await tester.pumpWidget(const ConfigErrorApp());
    expect(find.text('Falta configurar Supabase'), findsOneWidget);
    expect(find.byIcon(Icons.settings_suggest_outlined), findsOneWidget);
  });
}
