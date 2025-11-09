enum TGUnit { mgdl, mmoll }
enum GlucoseUnit { mgdl, mmoll }

extension TGUnitLabel on TGUnit {
  String get label => this == TGUnit.mgdl ? 'mg/dL' : 'mmol/L';
}
extension GlucoseUnitLabel on GlucoseUnit {
  String get label => this == GlucoseUnit.mgdl ? 'mg/dL' : 'mmol/L';
}

class Measurements {
  final double? triglycerides; // as entered by user
  final TGUnit tgUnit;
  final double? glucose;       // as entered by user
  final GlucoseUnit glucoseUnit;
  final double? weightKg;
  final double? heightCm;
  final double? waistCm;

  const Measurements({
    this.triglycerides,
    this.tgUnit = TGUnit.mgdl,
    this.glucose,
    this.glucoseUnit = GlucoseUnit.mgdl,
    this.weightKg,
    this.heightCm,
    this.waistCm,
  });

  Measurements copyWith({
    double? triglycerides,
    TGUnit? tgUnit,
    double? glucose,
    GlucoseUnit? glucoseUnit,
    double? weightKg,
    double? heightCm,
    double? waistCm,
  }) {
    return Measurements(
      triglycerides: triglycerides ?? this.triglycerides,
      tgUnit: tgUnit ?? this.tgUnit,
      glucose: glucose ?? this.glucose,
      glucoseUnit: glucoseUnit ?? this.glucoseUnit,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      waistCm: waistCm ?? this.waistCm,
    );
  }
}

class CalcResult {
  final double? heightM;
  final double? triglyceridesMgdl;
  final double? glucoseMgdl;
  final double? bmi;
  final double? tygIndex;
  final double? absi;
  final double? tygAbsi;
  final String? error;

  const CalcResult({
    this.heightM,
    this.triglyceridesMgdl,
    this.glucoseMgdl,
    this.bmi,
    this.tygIndex,
    this.absi,
    this.tygAbsi,
    this.error,
  });

  bool get ready =>
      heightM != null &&
          triglyceridesMgdl != null &&
          glucoseMgdl != null &&
          bmi != null &&
          tygIndex != null &&
          absi != null &&
          tygAbsi != null &&
          error == null;
}
