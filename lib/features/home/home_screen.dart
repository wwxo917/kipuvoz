import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/async_x.dart';
import '../../core/utils/format.dart';
import '../../data/models/producto.dart';
import '../../providers/exchange_rate_provider.dart';
import '../../providers/movimientos_provider.dart';
import '../../providers/negocio_provider.dart';
import '../../providers/productos_provider.dart';
import '../../providers/voice_provider.dart';
import '../../shared/state_views.dart';
import '../../data/services/voice_command_service.dart';
import '../../shared/widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _abrirCapturaVoz(BuildContext context, WidgetRef ref) async {
    final vozService = ref.read(voiceCommandServiceProvider);
    final exchangeService = ref.read(exchangeRateServiceProvider);
    final productos = ref.read(productosProvider).dataOrNull ?? const <Producto>[];

    var escuchando = false;
    var textoDetectado = '';
    var errorVoz = '';
    final manualCtrl = TextEditingController();
    BorradorComandoVoz? borradorListo;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          Future<void> iniciarEscucha() async {
            setModalState(() {
              errorVoz = '';
              escuchando = true;
            });
            try {
              await vozService.escuchar(
                onResultado: (texto, esFinal) {
                  if (!ctx.mounted) return;
                  setModalState(() {
                    textoDetectado = texto;
                    if (manualCtrl.text != texto) {
                      manualCtrl.value = TextEditingValue(
                        text: texto,
                        selection: TextSelection.collapsed(offset: texto.length),
                      );
                    }
                    if (esFinal) escuchando = false;
                  });
                },
              );
            } catch (e) {
              if (!ctx.mounted) return;
              setModalState(() {
                escuchando = false;
                errorVoz = e.toString();
              });
            }
          }

          Future<void> detenerYProcesar() async {
            await vozService.detener();
            if (!ctx.mounted) return;
            setModalState(() => escuchando = false);

            final frase = manualCtrl.text.trim().isNotEmpty
                ? manualCtrl.text.trim()
                : textoDetectado.trim();
            if (frase.isEmpty) {
              setModalState(() {
                errorVoz = 'Di o escribe una frase, por ejemplo: "Vendí 5 arroz a 40".';
              });
              return;
            }

            final borrador = await vozService.interpretar(
              texto: frase,
              productos: productos,
              exchangeService: exchangeService,
            );
            if (!ctx.mounted) return;
            borradorListo = borrador;
            Navigator.of(ctx).pop();
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  escuchando ? 'Escuchando… habla ahora' : 'Comando por voz',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ejemplo: "Vendí 5 arroz a 40" o "Compré 2 azúcar a 3 dólares"',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: manualCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Texto reconocido / prueba',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (errorVoz.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorVoz,
                    style: TextStyle(color: Theme.of(ctx).colorScheme.error, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: escuchando ? null : iniciarEscucha,
                        icon: Icon(escuchando ? Icons.mic : Icons.mic_none),
                        label: Text(escuchando ? 'Escuchando...' : 'Hablar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: detenerYProcesar,
                        child: const Text('Continuar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await vozService.detener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      manualCtrl.dispose();
    });

    if (borradorListo != null && context.mounted) {
      context.push(Routes.confirmation, extra: borradorListo);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final negocio = ref.watch(negocioProvider).dataOrNull;
    final movimientos = ref.watch(movimientosProvider);
    final tipoCambio = ref.watch(tipoCambioProvider).valueOrNull;

    final nombre = negocio?.nombre ?? 'Mi negocio';
    final inicial = nombre.isEmpty ? 'K' : nombre.substring(0, 1).toUpperCase();
    final hora = DateTime.now().hour;
    final saludo = hora < 12 ? 'Buenos días' : (hora < 19 ? 'Buenas tardes' : 'Buenas noches');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(saludo, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                      Text(
                        nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Cuenta y negocio',
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.push(Routes.settings),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      child: Text(inicial, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            HeroCard(label: 'Ganancia de hoy', value: bs(320), chip: '↑ 12 % que ayer', valueSize: 44),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: StatCard(icon: Icons.north_east, color: scheme.primary, label: 'Ventas', value: bs(540))),
                const SizedBox(width: 12),
                Expanded(child: StatCard(icon: Icons.south_west, color: scheme.error, label: 'Gastos', value: bs(220))),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tipoCambio != null
                  ? 'Ref. USD: 1 USD = ${tipoCambio.tasaBob.toStringAsFixed(2)} Bs (ExchangeRate-API)'
                  : 'Resumen de ejemplo: se conectará a tus movimientos en el Sprint 3.',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  MicButton(onPressed: () => _abrirCapturaVoz(context, ref)),
                  const SizedBox(height: 36),
                  Text.rich(
                    TextSpan(
                      style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      children: const [
                        TextSpan(text: 'Toca y di: '),
                        TextSpan(text: '“Vendí 5 arroz a 40”', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(Routes.entry),
                    child: const Text('Registrar sin voz'),
                  ),
                ],
              ),
            ),

            const SectionTitle('Últimos movimientos', top: 0),
            movimientos.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(
                message: friendlyError(e),
                onRetry: () => ref.read(movimientosProvider.notifier).cargar(),
              ),
              data: (lista) {
                if (lista.isEmpty) {
                  return const EmptyView(
                    icon: Icons.receipt_long_outlined,
                    title: 'Aún no tienes movimientos',
                    message: 'Registra tu primera venta con el micrófono o con “Registrar sin voz”.',
                  );
                }
                final recientes = lista.take(2).toList();
                return AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      for (var i = 0; i < recientes.length; i++) ...[
                        MovementTile(movimiento: recientes[i]),
                        if (i < recientes.length - 1) const Divider(),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}