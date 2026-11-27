import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/utils/async_x.dart';
import '../../data/models/movimiento.dart';
import '../../data/models/producto.dart';
import '../../data/services/consulta_voz_service.dart';
import '../../providers/movimientos_provider.dart';
import '../../providers/productos_provider.dart';
import '../../shared/widgets.dart';

/// HU-16: consulta dictada con respuesta hablada basada en datos del usuario.
class ConsultaVozSheet extends ConsumerStatefulWidget {
  const ConsultaVozSheet({super.key});
  @override
  ConsumerState<ConsultaVozSheet> createState() => _ConsultaVozSheetState();
}

class _ConsultaVozSheetState extends ConsumerState<ConsultaVozSheet> {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _texto = TextEditingController();
  String _respuesta = '';
  String _error = '';
  bool _escuchando = false;
  bool _procesando = false;

  @override
  void dispose() {
    unawaited(_stt.stop());
    unawaited(_tts.stop());
    _texto.dispose();
    super.dispose();
  }

  Future<void> _escuchar() async {
    setState(() { _error = ''; _escuchando = true; });
    try {
      if (!await _stt.initialize()) throw StateError('No hay micrófono disponible.');
      final locales = await _stt.locales();
      String? idioma;
      for (final local in locales) {
        if (local.localeId.toLowerCase().startsWith('es')) {
          idioma = local.localeId;
          if (local.localeId.toLowerCase().contains('bo')) break;
        }
      }
      await _stt.listen(
        localeId: idioma ?? 'es_BO',
        onResult: (resultado) {
          if (!mounted) return;
          setState(() {
            _texto.text = resultado.recognizedWords;
            if (resultado.finalResult) _escuchando = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() { _escuchando = false; _error = 'No se pudo escuchar. Puedes escribir tu pregunta. $e'; });
    }
  }

  Future<void> _consultar() async {
    final pregunta = _texto.text.trim();
    if (pregunta.isEmpty) {
      setState(() => _error = 'Primero di o escribe una pregunta.');
      return;
    }
    setState(() { _procesando = true; _error = ''; });
    try {
      await _stt.stop();
      final mov = ref.read(movimientosProvider).dataOrNull ?? const <Movimiento>[];
      final productos = ref.read(productosProvider).dataOrNull ?? const <Producto>[];
      final respuesta = ConsultaVozService.responder(pregunta,
          movimientos: mov, productos: productos);
      if (!mounted) return;
      setState(() { _respuesta = respuesta; _escuchando = false; });
      await _hablar();
    } catch (e) {
      if (mounted) setState(() => _error = 'No se pudo consultar: $e');
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _hablar() async {
    if (_respuesta.isEmpty) return;
    try {
      await _tts.setLanguage('es-ES');
      await _tts.setSpeechRate(0.48);
      await _tts.speak(_respuesta);
    } catch (_) {
      if (mounted) showMessage(context, 'El dispositivo no pudo leer la respuesta en voz alta.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 20, 18, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Consulta por voz', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Pregunta "¿Cuánto vendí hoy?", "¿Cuál es mi saldo?" o "¿Cuánto stock tengo de arroz?".'),
          const SizedBox(height: 12),
          TextField(
            controller: _texto,
            decoration: appInput(label: 'Tu pregunta', helper: 'Puedes hablar o escribir.'),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: _escuchando || _procesando ? null : _escuchar,
              icon: const Icon(Icons.mic_none),
              label: Text(_escuchando ? 'Escuchando...' : 'Hablar'),
            )),
            const SizedBox(width: 8),
            Expanded(child: FilledButton.icon(
              onPressed: _procesando ? null : _consultar,
              icon: const Icon(Icons.question_answer_outlined),
              label: const Text('Consultar'),
            )),
          ]),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_error, style: TextStyle(color: scheme.error)),
          ],
          if (_respuesta.isNotEmpty) ...[
            const SizedBox(height: 14),
            AppCard(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Respuesta basada en tus datos de Supabase',
                  style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(_respuesta),
                TextButton.icon(onPressed: _hablar, icon: const Icon(Icons.volume_up_outlined),
                  label: const Text('Escuchar de nuevo')),
              ],
            )),
          ],
        ],
      )),
    );
  }
}
