// All numeric helpers and unit conversions

double? parseDouble(String s) {
  final t = s.trim();
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

double cmToM(double cm) => cm / 100.0;

// Triglycerides mmol/L -> mg/dL
double tgMmollToMgdl(double mmolL) => mmolL * 88.57;

// Glucose mmol/L -> mg/dL
double gluMmollToMgdl(double mmolL) => mmolL * 18.0;
