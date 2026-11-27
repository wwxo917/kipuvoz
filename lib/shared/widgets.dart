import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../data/models/movimiento.dart';

/// Color suave (fondo de íconos y chips) a partir de un color del tema.
Color tintOf(BuildContext context, Color color, [double alpha = 0.14]) =>
    Color.alphaBlend(color.withValues(alpha: alpha), Theme.of(context).colorScheme.surface);

/// Mensaje breve (confirmación o error) en la parte inferior.
void showMessage(BuildContext context, String message, {bool error = false}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(fontSize: 14, color: error ? scheme.onError : null)),
      backgroundColor: error ? scheme.error : null,
      behavior: SnackBarBehavior.floating,
    ));
}

/// Aviso para funciones que llegan en sprints posteriores.
void showSoon(BuildContext context, [String message = 'Disponible en un sprint posterior']) =>
    showMessage(context, message);

/// Diálogo de confirmación (por ejemplo, antes de archivar o cerrar sesión).
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String accion,
  bool peligro = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
        TextButton(
          style: peligro ? TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error) : null,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(accion),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Decoración común de los campos de formulario (FB-04: con texto de ayuda).
InputDecoration appInput({
  String? label,
  String? helper,
  String? hint,
  String? error,
  Widget? prefix,
  Widget? suffix,
  String? prefixText,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecoration(
    labelText: label,
    helperText: helper,
    helperMaxLines: 2,
    hintText: hint,
    errorText: error,
    errorMaxLines: 2,
    prefixIcon: prefix,
    suffixIcon: suffix,
    prefixText: prefixText,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(AppColors.line),
    enabledBorder: border(AppColors.line),
    focusedBorder: border(AppColors.primary, 2),
    errorBorder: border(AppColors.alert),
    focusedErrorBorder: border(AppColors.alert, 2),
    labelStyle: const TextStyle(color: AppColors.muted, fontSize: 16),
    helperStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
    errorStyle: const TextStyle(color: AppColors.alert, fontSize: 14, fontWeight: FontWeight.w600),
  );
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.color, this.iconColor, this.size = 42});

  final IconData icon;
  final Color color; // color del fondo suave
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tintOf(context, color, color == Theme.of(context).colorScheme.secondary ? 0.28 : 0.14),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      // FB-02: íconos de al menos 24 dp
      child: Icon(icon, size: size * 0.6, color: iconColor ?? color),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.top = 18});

  final String text;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.label, required this.value, required this.chip, this.valueSize = 36});

  final String label;
  final String value;
  final String chip;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, Color.lerp(scheme.primary, Colors.white, 0.15)!],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.bodyMedium?.copyWith(color: scheme.onPrimary.withValues(alpha: 0.9))),
          const SizedBox(height: 2),
          Text(
            value,
            style: text.displaySmall?.copyWith(fontSize: valueSize, fontWeight: FontWeight.w800, color: scheme.onPrimary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(chip, style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: scheme.onPrimary)),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.icon, required this.color, required this.label, required this.value});

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            IconBadge(icon: icon, color: color, size: 40),
            const SizedBox(width: 8),
            Text(label, style: text.bodySmall?.copyWith(color: muted)),
          ]),
          const SizedBox(height: 8),
          Text(value, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Movimiento del historial: ingresos y gastos se distinguen por color, ícono y signo (FB-01).
class MovementTile extends StatelessWidget {
  const MovementTile({super.key, required this.movimiento, this.onTap});

  final Movimiento movimiento;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final (Color bg, Color fg, IconData icon) = switch (movimiento.tipo) {
      TipoMovimiento.venta => (scheme.primary, scheme.primary, Icons.north_east),
      TipoMovimiento.gasto => (scheme.error, scheme.error, Icons.south_west),
      TipoMovimiento.compra => (scheme.secondary, scheme.onSurface, Icons.shopping_bag_outlined),
    };
    final esVenta = movimiento.tipo == TipoMovimiento.venta;
    final monto = movimiento.anulado ? bs(0) : (esVenta ? bs(movimiento.total, sign: true) : bs(-movimiento.total));
    final anulado = movimiento.anulado ? ' · Anulado' : '';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: IconBadge(icon: icon, color: bg, iconColor: fg),
      title: Text(
        movimiento.detalle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600,
            decoration: movimiento.anulado ? TextDecoration.lineThrough : null),
      ),
      subtitle: Text(
        '${movimiento.tipo.etiqueta} · ${dateLabel(movimiento.fecha)} · ${timeLabel(movimiento.fecha)}$anulado',
        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      trailing: Text(
        monto,
        style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: esVenta ? scheme.primary : scheme.error),
      ),
    );
  }
}

class MicButton extends StatelessWidget {
  const MicButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Dictar un movimiento por voz',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.secondary,
            boxShadow: [
              BoxShadow(color: scheme.secondary.withValues(alpha: 0.24), spreadRadius: 10),
              BoxShadow(color: scheme.secondary.withValues(alpha: 0.12), spreadRadius: 22),
            ],
          ),
          child: Icon(Icons.mic, size: 40, color: scheme.onSecondary),
        ),
      ),
    );
  }
}

/// Fila de filtros (chips) de una sola selección.
class ChipFilterRow extends StatelessWidget {
  const ChipFilterRow({super.key, required this.labels, required this.selected, required this.onSelected});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (var i = 0; i < labels.length; i++)
          FilterChip(
            label: Text(
              labels[i],
              style: TextStyle(
                fontSize: 14,
                fontWeight: i == selected ? FontWeight.w700 : FontWeight.w600,
                color: i == selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
            selected: i == selected,
            showCheckmark: false,
            onSelected: (_) => onSelected(i),
          ),
      ],
    );
  }
}
