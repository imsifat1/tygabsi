import 'package:flutter/material.dart';
import '../../domain/models.dart';

class ResultsCard extends StatelessWidget {
  final CalcResult result;
  const ResultsCard({super.key, required this.result});

  String fmt(double? v) => v == null ? '—' : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    if (result.error != null) {
      return _Error(result.error!);
    }

    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.insights_rounded, color: cs.primary),
              const SizedBox(width: 8),
              Text('Results', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            _BigNumber(
              label: 'TyG-ABSI (Final)',
              value: fmt(result.tygAbsi),
              subtitle: 'TyG Index × ABSI',
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('See details'),
              childrenPadding: EdgeInsets.zero,
              children: [
                const Divider(),
                _row('Height (m)', fmt(result.heightM)),
                _row('Triglycerides (mg/dL)', fmt(result.triglyceridesMgdl)),
                _row('Glucose (mg/dL)', fmt(result.glucoseMgdl)),
                _row('BMI', fmt(result.bmi)),
                _row('TyG Index (ln)', fmt(result.tygIndex)),
                _row('ABSI', fmt(result.absi)),
                const SizedBox(height: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _BigNumber extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  const _BigNumber({required this.label, required this.value, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
      child: Column(
        key: ValueKey(value),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelLarge),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                value,
                style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: textTheme.bodySmall),
          ],
          const SizedBox(height: 8),
          Text(
            'Risk bands (overall): <0.65 low · 0.65–0.70 borderline · 0.70–0.76 elevated · ≥0.76 high.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  const _Error(this.message);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: cs.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
