import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../application/tyg_absi_notifier.dart';
import '../domain/models.dart';
import 'widgets/animated_header_backdrop.dart';
import 'widgets/input_field.dart';
import 'widgets/result_card.dart';

final resetTriggerProvider = StateProvider<int>((ref) => 0);
class TygAbsiScreen extends ConsumerWidget {
  const TygAbsiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resetToken = ref.watch(resetTriggerProvider);
    final result = ref.watch(resultProvider);

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('TyG-ABSI'),
              centerTitle: false,
              pinned: true,
              actions: [
                IconButton(
                  tooltip: 'Info',
                  onPressed: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'TyG-ABSI Calculator',
                      applicationVersion: '1.0.0',
                      children: const [
                        Text(
                            'Enter fasting triglycerides and glucose with correct units, plus weight, height and waist. '
                                'We convert units automatically and compute BMI → TyG → ABSI → TyG-ABSI.'
                        ),
                      ],
                    );
                  },
                  icon: const Icon(Icons.info_outline_rounded),
                ),
                IconButton(
                  tooltip: 'Reset',
                  onPressed: () {
                    ref.read(measurementsProvider.notifier).reset();
                    ref.read(resetTriggerProvider.notifier).state++; // force rebuild of TextFields
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: AnimatedHeaderBackdrop(),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(110),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeaderScoreCard(), // glass card with current score (if ready)
                      const SizedBox(height: 8),
                      PresetChips(),     // quick demo inputs
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SectionCard(
                    title: 'Blood Tests',
                    subtitle: 'Enter fasting values and pick the units.',
                    child: _BloodInputsRow(resetToken),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Body Measurements',
                    subtitle: 'Weight, height, and waist in centimeters/kilograms.',
                    child: _BodyInputs(resetToken),
                  ),
                  const SizedBox(height: 14),
                  ResultsCard(result: result),
                  const SizedBox(height: 18),
                  const _Note(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const _SectionCard({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      surfaceTintColor: cs.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_rounded, color: cs.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _BloodInputsRow extends StatelessWidget {
  const _BloodInputsRow(this.resetToken);
  final resetToken;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final isWide = c.maxWidth > 560;
        if (isWide) {
          return Row(
            children: [
              Expanded(child: TGInput(resetToken,)),
              SizedBox(width: 12),
              Expanded(child: GlucoseInput(resetToken,)),
            ],
          );
        }
        return Column(
          children: [
            TGInput(resetToken),
            SizedBox(height: 12),
            GlucoseInput(ValueKey('g-$resetToken'),),
          ],
        );
      },
    );
  }
}

class _BodyInputs extends StatelessWidget {
  const _BodyInputs(this.resetToken);
  final resetToken;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TwoCol(
          left: NumberField(
            key: ValueKey('w-$resetToken'),
            label: 'Weight',
            suffix: 'kg',
            kind: FieldKind.weight,
            prefixIcon: Icons.monitor_weight_outlined,
            hint: 'e.g., 70.5',
          ),
          right: NumberField(
            key: ValueKey('h-$resetToken'),
            label: 'Height',
            suffix: 'cm',
            kind: FieldKind.height,
            prefixIcon: Icons.height_rounded,
            hint: 'e.g., 170',
          ),
        ),
        const SizedBox(height: 12),
        NumberField(
          key: ValueKey('wc-$resetToken'),
          label: 'Waist Circumference',
          suffix: 'cm',
          kind: FieldKind.waist,
          prefixIcon: Icons.straighten_rounded,
          hint: 'e.g., 85',
          helper: 'Measure at the midpoint between rib and hip.',
        ),
      ],
    );
  }
}

class _TwoCol extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _TwoCol({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final isWide = c.maxWidth > 560;
      if (isWide) {
        return Row(children: [Expanded(child: left), const SizedBox(width: 12), Expanded(child: right)]);
      }
      return Column(children: [left, const SizedBox(height: 12), right]);
    });
  }
}

class _Note extends StatelessWidget {
  const _Note();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Note: Values are rounded to 2 decimals. Educational use only—this does not replace professional medical advice.',
      style: Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.center,
    );
  }
}

/// TG input with segmented units (mg/dL | mmol/L)
class TGInput extends ConsumerWidget {
  const TGInput(this.resetToken, {super.key});
  final resetToken;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(measurementsProvider);
    final notifier = ref.read(measurementsProvider.notifier);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Fasting Triglycerides', style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      NumberTextField(
        key: ValueKey('tg-$resetToken'),
        hint: 'e.g., 150 or 1.7',
        prefixIcon: Icons.opacity_rounded,
        onChanged: notifier.setTriglycerides,
        trailing: UnitSegmented<TGUnit>(
          value: m.tgUnit,
          segments: const {
            TGUnit.mgdl: 'mg/dL',
            TGUnit.mmoll: 'mmol/L',
          },
          onChanged: notifier.setTGUnit,
        ),
        helper: 'Enter mg/dL or switch to mmol/L (auto × 88.57).',
      ),
    ]);
  }
}

/// Glucose input with segmented units (mg/dL | mmol/L)
class GlucoseInput extends ConsumerWidget {
  const GlucoseInput(this.resetToken, {super.key});
  final resetToken;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(measurementsProvider);
    final notifier = ref.read(measurementsProvider.notifier);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Fasting Glucose', style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      NumberTextField(
        hint: 'e.g., 90 or 5.0',
        key: ValueKey('fg-$resetToken'),
        prefixIcon: Icons.bloodtype_rounded,
        onChanged: notifier.setGlucose,
        trailing: UnitSegmented<GlucoseUnit>(
          value: m.glucoseUnit,
          segments: const {
            GlucoseUnit.mgdl: 'mg/dL',
            GlucoseUnit.mmoll: 'mmol/L',
          },
          onChanged: notifier.setGlucoseUnit,
        ),
        helper: 'Enter mg/dL or switch to mmol/L (auto × 18).',
      ),
    ]);
  }
}
