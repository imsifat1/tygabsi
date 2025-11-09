import 'dart:math' as math;

double bmiFrom(double weightKg, double heightM) => weightKg / (heightM * heightM);

double tygIndexFrom(double tgMgdl, double gluMgdl) {
  final product = (tgMgdl * gluMgdl) / 2.0;
  if (product <= 0) throw ArgumentError('Invalid TyG product');
  return math.log(product); // natural log
}

/// ABSI = Waist(cm) / [ BMI^(2/3) × Height(cm)^(1/2) ]
double absiFrom({
  required double waistCm,
  required double bmi,
  required double heightCm,
}) {
  final den = math.pow(bmi, 2.0 / 3.0) * math.pow(heightCm, 0.5);
  if (den == 0 || !den.isFinite) {
    throw ArgumentError('Invalid ABSI denominator');
  }
  return waistCm / den;
}

double tygAbsiFrom(double tygIndex, double absi) => tygIndex * absi;
