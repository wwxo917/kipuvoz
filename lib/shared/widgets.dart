import 'package:flutter/material.dart';

import '../core/data/sample_data.dart';
import '../core/utils/format.dart';

/// Color suave (fondo de íconos y chips) a partir de un color de la paleta.
Color tintOf(BuildContext context, Color color, [double alpha = 0.14]) =>
    Color.alphaBlend(color.withValues(alpha: alpha), Theme.of(context).colorScheme.surface);

/// Aviso para funciones que llegan en sprints posteriores.
void showSoon(BuildContext context, [String message = 'Disponible en el Sprint 2']) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
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
      child: Icon(icon, size: size * 0.5, color: iconColor ?? color),
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
  const HeroCard({super.key, required this.label, required this.value, required this.chip});

  final String label;
  final String value;
  final String chip;

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
          Text(label, style: text.bodyMedium?.copyWith(color: scheme.onPrimary.withValues(alpha: 0.85))),
          const SizedBox(height: 2),
          Text(value, style: text.displaySmall?.copyWith(fontWeight: FontWeight.w800, color: scheme.onPrimary)),
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
            IconBadge(icon: icon, color: color, size: 32),
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

class MovementTile extends StatelessWidget {
  const MovementTile({super.key, required this.movement, this.onTap});

  final Movement movement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final (Color bg, Color fg, IconData icon) = switch (movement.type) {
      MovementType.sale => (scheme.primary, scheme.primary, Icons.north_east),
      MovementType.expense => (scheme.error, scheme.error, Icons.south_west),
      MovementType.purchase => (scheme.secondary, scheme.onSurface, Icons.shopping_bag_outlined),
    };
    final isSale = movement.type == MovementType.sale;
    final amount = isSale ? bs(movement.amount, sign: true) : bs(-movement.amount);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: IconBadge(icon: icon, color: bg, iconColor: fg),
      title: Text(movement.items, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text('${movement.type.label} · ${movement.date} · ${movement.time}',
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
      trailing: Text(
        amount,
        style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: isSale ? scheme.primary : scheme.error),
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
                fontSize: 13,
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
