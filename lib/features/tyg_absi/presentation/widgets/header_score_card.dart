
// Glassy score card docked at the bottom of the app bar
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/tyg_absi_notifier.dart';
import '../../domain/risk.dart';

class HeaderScoreCard extends ConsumerWidget {
  const HeaderScoreCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(resultProvider);
    final risk = ref.watch(riskProvider);
    final cs = Theme.of(context).colorScheme;

    final bool ready = (result.error == null && result.tygAbsi != null);
    // Show only the “big number” when ready; otherwise a hint
    // final String title = (result.error == null && result.tygAbsi != null)
    //     ? 'TyG-ABSI'
    //     : 'Ready to calculate TyG-ABSI';
    final String value = (result.error == null && result.tygAbsi != null)
        ? (result.tygAbsi!).toStringAsFixed(2)
        : 'Enter all inputs';

    // Choose colors based on risk
    Color bg;
    Color border;
    Color iconBg;
    Color iconColor;
    String title;
    String subtitle;

    if (!ready) {
      bg = cs.surface.withOpacity(0.55);
      border = cs.outlineVariant.withOpacity(0.5);
      iconBg = cs.primary.withOpacity(0.16);
      iconColor = cs.primary;
      title = 'Ready to calculate';
      subtitle = 'Fasting TG, Glucose, Weight, Height, Waist';
    } else {
      switch (risk?.level) {
        case RiskLevel.high:
          bg = cs.errorContainer.withOpacity(0.85);
          border = cs.error.withOpacity(0.40);
          iconBg = cs.error.withOpacity(0.20);
          iconColor = cs.onErrorContainer;
          title = risk!.title;
          subtitle = risk.tip;
          break;
        case RiskLevel.elevated:
          bg = cs.tertiaryContainer.withOpacity(0.80);
          border = cs.tertiary.withOpacity(0.35);
          iconBg = cs.tertiary.withOpacity(0.18);
          iconColor = cs.onTertiaryContainer;
          title = risk!.title;
          subtitle = risk.tip;
          break;
        case RiskLevel.borderline:
          bg = cs.secondaryContainer.withOpacity(0.80);
          border = cs.secondary.withOpacity(0.30);
          iconBg = cs.secondary.withOpacity(0.16);
          iconColor = cs.onSecondaryContainer;
          title = risk!.title;
          subtitle = risk.tip;
          break;
        case RiskLevel.low:
        default:
          bg = cs.primaryContainer.withOpacity(0.80);
          border = cs.primary.withOpacity(0.30);
          iconBg = cs.primary.withOpacity(0.16);
          iconColor = cs.onPrimaryContainer;
          title = 'Low risk';
          subtitle = 'Keep steady habits; re-check after lifestyle changes.';
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
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
                    const SizedBox(height: 6),
                    Text(ready ? 'TyG Index × ABSI — $subtitle' : subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
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