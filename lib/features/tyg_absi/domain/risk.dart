import 'models.dart';

enum RiskLevel { low, borderline, elevated, high }

class RiskAssessment {
  final RiskLevel level;
  final String title;
  final String tip;
  const RiskAssessment(this.level, this.title, this.tip);
}

/// He et al. (Cardiovascular Diabetology, 2025):
/// - TyG-ABSI quartiles used around ~0.65, 0.70, 0.76.
/// - Risk rose notably when TyG-ABSI > 0.76 (overall; diabetics had a J-shape).
/// - High TyG (>9.04) + high ABSI (>0.085) = worst mortality risk group.
/// We translate this into app-friendly bands.
///
/// Bands (overall population):
///  <0.65 → Low
///  0.65–<0.70 → Borderline
///  0.70–<0.76 → Elevated
///  ≥0.76 → High
RiskAssessment assessRisk({
  required double tygAbsi,
  double? tygIndex,
  double? absi,
}) {
  // Default band on TyG-ABSI
  RiskLevel level;
  if (tygAbsi >= 7.68) {
    level = RiskLevel.high;
  } else if (tygAbsi >= 7.1) {
    level = RiskLevel.elevated;
  } else if (tygAbsi >= 6.5) {
    level = RiskLevel.borderline;
  } else {
    level = RiskLevel.low;
  }

  // Strong red flag if BOTH TyG and ABSI exceed the paper’s “high” cutoffs.
  final bool synergyFlag =
      (tygIndex != null && tygIndex > 9.04) &&
          (absi != null && absi > 0.85);

  String title;
  String tip;

  switch (level) {
    case RiskLevel.low:
      title = 'Low risk';
      tip = 'Keep up healthy habits (balanced diet, regular activity, sleep, avoid smoking).';
      break;
    case RiskLevel.borderline:
      title = 'Borderline';
      tip = 'Consider lifestyle tune-ups: fiber-rich diet, walking 150+ min/week, weight control.';
      break;
    case RiskLevel.elevated:
      title = 'Elevated';
      tip = 'Focus on improving triglycerides, fasting glucose, and waist. Track changes over time.';
      break;
    case RiskLevel.high:
      title = 'High risk';
      tip = 'Discuss results with a clinician. Address insulin resistance and visceral fat; monitor BP/lipids.';
      break;
  }

  if (synergyFlag) {
    title = 'High risk (TyG & ABSI both high)';
    tip = 'Combined high insulin-resistance marker and central adiposity elevate risk — seek medical advice.';
  }

  return RiskAssessment(level, title, tip);
}
