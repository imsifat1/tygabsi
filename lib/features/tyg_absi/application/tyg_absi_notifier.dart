// lib/features/tyg_absi/application/tyg_absi_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:flutter_riverpod/legacy.dart' as rp;

import '../domain/models.dart';
import '../domain/conversions.dart';
import '../domain/calculations.dart';

class TygAbsiNotifier extends rp.StateNotifier<Measurements> {
  TygAbsiNotifier() : super(const Measurements());

  void setTriglycerides(String v) =>
      state = state.copyWith(triglycerides: parseDouble(v));
  void setTGUnit(TGUnit u) => state = state.copyWith(tgUnit: u);

  void setGlucose(String v) =>
      state = state.copyWith(glucose: parseDouble(v));
  void setGlucoseUnit(GlucoseUnit u) =>
      state = state.copyWith(glucoseUnit: u);

  void setWeight(String v) => state = state.copyWith(weightKg: parseDouble(v));
  void setHeight(String v) => state = state.copyWith(heightCm: parseDouble(v));
  void setWaist(String v) => state = state.copyWith(waistCm: parseDouble(v));
  void reset() => state = const Measurements();
}

final measurementsProvider =
rp.StateNotifierProvider<TygAbsiNotifier, Measurements>(
      (ref) => TygAbsiNotifier(),
);

final resultProvider = rp.Provider<CalcResult>((ref) {
  final m = ref.watch(measurementsProvider);

  // Require all inputs
  if (m.triglycerides == null ||
      m.glucose == null ||
      m.weightKg == null ||
      m.heightCm == null ||
      m.waistCm == null) {
    return const CalcResult(error: 'Enter all fields to calculate.');
  }

  final tgIn = m.triglycerides!;
  final gluIn = m.glucose!;
  final wKg = m.weightKg!;
  final hCm = m.heightCm!;
  final waist = m.waistCm!;

  if (tgIn <= 0 || gluIn <= 0 || wKg <= 0 || hCm <= 0 || waist <= 0) {
    return const CalcResult(error: 'All values must be greater than zero.');
  }

  // Conversions
  final heightM = cmToM(hCm);
  final tgMgdl = m.tgUnit == TGUnit.mgdl ? tgIn : tgMmollToMgdl(tgIn);
  final gluMgdl =
  m.glucoseUnit == GlucoseUnit.mgdl ? gluIn : gluMmollToMgdl(gluIn);

  try {
    final bmi = bmiFrom(wKg, heightM);
    final tyg = tygIndexFrom(tgMgdl, gluMgdl);
    final absi = absiFrom(waistCm: waist, bmi: bmi, heightCm: hCm);
    final score = tygAbsiFrom(tyg, absi);

    return CalcResult(
      heightM: heightM,
      triglyceridesMgdl: tgMgdl,
      glucoseMgdl: gluMgdl,
      bmi: bmi,
      tygIndex: tyg,
      absi: absi,
      tygAbsi: score,
    );
  } catch (e) {
    return CalcResult(error: 'Calculation error: ${e.toString()}');
  }
});
