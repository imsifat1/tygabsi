import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/tyg_absi_notifier.dart';

// Animated gradient + soft blobs
class AnimatedHeaderBackdrop extends StatefulWidget {
  @override
  State<AnimatedHeaderBackdrop> createState() => _AnimatedHeaderBackdropState();
}

class _AnimatedHeaderBackdropState extends State<AnimatedHeaderBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Animated gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer,
                    cs.secondaryContainer.withOpacity(0.85),
                    cs.surface,
                  ],
                  begin: Alignment(-0.8 + 0.6 * t, -1.0),
                  end: Alignment(1.0, 0.6 - 0.4 * t),
                ),
              ),
            ),
            // Soft "blob" accents
            Positioned(
              left: 40 + 20 * t,
              top: 50,
              child: _Blob(color: cs.primary.withOpacity(0.18), size: 140),
            ),
            Positioned(
              right: 24,
              bottom: 30 + 15 * (1 - t),
              child: _Blob(color: cs.tertiary.withOpacity(0.16), size: 110),
            ),
          ],
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 40, spreadRadius: 10)],
      ),
    );
  }
}

// Glassy score card docked at the bottom of the app bar
class HeaderScoreCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(resultProvider);
    final cs = Theme.of(context).colorScheme;

    // Show only the “big number” when ready; otherwise a hint
    final String title = (result.error == null && result.tygAbsi != null)
        ? 'TyG-ABSI'
        : 'Ready to calculate';
    final String value = (result.error == null && result.tygAbsi != null)
        ? (result.tygAbsi!).toStringAsFixed(2)
        : 'Enter all inputs';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.insights_rounded, color: cs.primary),
              ),
              const SizedBox(width: 12,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 0),
                    Text(
                      (result.error == null && result.tygAbsi != null)
                          ? 'TyG Index × ABSI'
                          : 'Fasting TG, Glucose, Weight, Height, Waist',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  value,
                  key: ValueKey(value),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Preset chips for quick demo / testing
class PresetChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(measurementsProvider.notifier);

    void applyNormal() {
      n.setTriglycerides('120'); // mg/dL default
      n.setGlucose('90');        // mg/dL default
      n.setWeight('70');
      n.setHeight('170');
      n.setWaist('84');
    }

    void applyElevated() {
      n.setTriglycerides('220'); // mg/dL
      n.setGlucose('130');       // mg/dL
      n.setWeight('92');
      n.setHeight('168');
      n.setWaist('102');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _PresetChip(
          icon: Icons.flash_on_rounded,
          label: 'Preset: Normal',
          onTap: applyNormal,
        ),
        _PresetChip(
          icon: Icons.trending_up_rounded,
          label: 'Preset: Elevated',
          onTap: applyElevated,
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: cs.onSecondaryContainer),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: cs.onSecondaryContainer)),
          ],
        ),
      ),
    );
  }
}
