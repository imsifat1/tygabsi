import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/tyg_absi_notifier.dart';

enum FieldKind { weight, height, waist }

class NumberField extends ConsumerWidget {
  final String label;
  final String suffix;
  final FieldKind kind;
  final IconData? prefixIcon;
  final String? hint;
  final String? helper;

  const NumberField({
    super.key,
    required this.label,
    required this.suffix,
    required this.kind,
    this.prefixIcon,
    this.hint,
    this.helper,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onChanged(String v) {
      final n = ref.read(measurementsProvider.notifier);
      switch (kind) {
        case FieldKind.weight:
          n.setWeight(v);
          break;
        case FieldKind.height:
          n.setHeight(v);
          break;
        case FieldKind.waist:
          n.setWaist(v);
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        NumberTextField(
          hint: hint ?? 'e.g., 70.5',
          prefixIcon: prefixIcon,
          suffixText: suffix,
          onChanged: onChanged,
          helper: helper,
        ),
      ],
    );
  }
}

/// Reusable numeric text field with optional unit chip on the trailing side
class NumberTextField extends StatelessWidget {
  final String hint;
  final IconData? prefixIcon;
  final String? suffixText;
  final Widget? trailing;
  final String? helper;
  final ValueChanged<String> onChanged;

  const NumberTextField({
    super.key,
    required this.hint,
    this.prefixIcon,
    this.suffixText,
    this.trailing,
    this.helper,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        hintText: hint,
        suffixText: trailing == null ? suffixText : null,
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: field),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(helper!, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ],
    );
  }
}

/// Generic segmented unit selector
class UnitSegmented<T> extends StatelessWidget {
  final T value;
  final Map<T, String> segments;
  final ValueChanged<T> onChanged;

  const UnitSegmented({
    super.key,
    required this.value,
    required this.segments,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: segments.entries
          .map((e) => ButtonSegment<T>(value: e.key, label: Text(e.value)))
          .toList(),
      selected: {value},
      onSelectionChanged: (set) {
        if (set.isNotEmpty) onChanged(set.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
      ),
    );
  }
}
