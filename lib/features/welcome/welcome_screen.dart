import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/routes.dart';

/// HU-01: bienvenida con logo, nombre, eslogan y 3 pantallas deslizables.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Color.lerp(scheme.primary, Colors.black, 0.6)!;
    final mid = Color.lerp(scheme.primary, dark, 0.5)!;

    final slides = <Widget>[
      _Slide(
        visual: Icons.mic,
        extra: _Cord(color: scheme.secondary),
        title: 'KipuVoz',
        titleSize: 40,
        text: 'Habla, y tus cuentas\nse anotan solas.',
      ),
      const _Slide(
        visual: Icons.graphic_eq,
        title: 'Registra hablando',
        text: 'Di “vendí 5 arroz a 40” y la app arma el registro por ti. Tú solo confirmas.',
      ),
      const _Slide(
        visual: Icons.inventory_2_outlined,
        title: 'Controla tu negocio',
        text: 'Mira tu stock, tus movimientos y tu ganancia del día, la semana o el mes.',
      ),
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [dark, mid]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                // Pantallas deslizables
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: slides,
                  ),
                ),
                // Indicador de página
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < slides.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: i == _page ? scheme.secondary : Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                // Botón principal (>= 48 dp de alto): lleva a la pantalla principal
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: scheme.secondary,
                    foregroundColor: scheme.onSecondary,
                  ),
                  onPressed: () => context.go(Routes.login),
                  child: const Text('Comenzar'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.visual, required this.title, required this.text, this.extra, this.titleSize = 28});

  final IconData visual;
  final String title;
  final String text;
  final Widget? extra;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.12)),
              child: Center(
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.secondary),
                  child: Icon(visual, size: 44, color: scheme.onSecondary),
                ),
              ),
            ),
            if (extra != null) ...[const SizedBox(height: 14), extra!],
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.45, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cuerda con nudos: referencia al kipu andino.
class _Cord extends StatelessWidget {
  const _Cord({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget line() => Container(width: 34, height: 2, color: Colors.white.withValues(alpha: 0.5));
    Widget knot() => Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.symmetric(horizontal: 3.5),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [line(), const SizedBox(width: 4), knot(), knot(), knot(), const SizedBox(width: 4), line()],
    );
  }
}
