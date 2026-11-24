import 'package:flutter/material.dart';

import 'widgets.dart';

class PickerItem<T> {
  const PickerItem(this.value, this.label);

  final T value;
  final String label;
}

/// Campo de selección con lista (hoja inferior). Funciona dentro de un Form y admite validator.
class PickerField<T> extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
    this.helper,
  });

  final String label;
  final List<PickerItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      key: ValueKey<Object?>(value),
      initialValue: value,
      validator: validator,
      builder: (state) {
        PickerItem<T>? selected;
        for (final item in items) {
          if (item.value == state.value) selected = item;
        }
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final result = await showModalBottomSheet<PickerItem<T>>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (ctx) => _PickerSheet<T>(title: label, items: items, selected: state.value),
            );
            if (result != null) {
              state.didChange(result.value);
              onChanged(result.value);
            }
          },
          child: InputDecorator(
            isEmpty: selected == null,
            decoration: appInput(
              label: label,
              helper: helper,
              error: state.errorText,
              suffix: const Icon(Icons.arrow_drop_down),
            ),
            child: Text(selected?.label ?? '', style: Theme.of(context).textTheme.bodyLarge),
          ),
        );
      },
    );
  }
}

class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({required this.title, required this.items, required this.selected});

  final String title;
  final List<PickerItem<T>> items;
  final T? selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final item in items)
                    ListTile(
                      title: Text(item.label),
                      trailing: item.value == selected ? Icon(Icons.check, color: scheme.primary) : null,
                      onTap: () => Navigator.of(context).pop(item),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo de contraseña con botón para mostrar u ocultar.
class PasswordField extends StatefulWidget {
  const PasswordField({super.key, required this.controller, required this.label, this.validator, this.helper, this.action});

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final String? helper;
  final TextInputAction? action;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _oculta,
      validator: widget.validator,
      textInputAction: widget.action,
      decoration: appInput(
        label: widget.label,
        helper: widget.helper,
        suffix: IconButton(
          tooltip: _oculta ? 'Mostrar contraseña' : 'Ocultar contraseña',
          icon: Icon(_oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _oculta = !_oculta),
        ),
      ),
    );
  }
}
