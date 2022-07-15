import 'package:harmony_theory/modals/progression/degree_progression.dart';
import 'package:harmony_theory/modals/weights/harmonic_function_weight.dart';
import 'package:test/test.dart';

main() {
  test('Harmonic Bank Assertions', () {
    Map<int, Map<int?, int>> sorted =
        HarmonicFunctionWeight.sortedFunctions.hashMap;
    for (int k in sorted.keys) {
      expect(
        sorted[k]!.values,
        everyElement(
          allOf(
            greaterThanOrEqualTo(
                -1 * HarmonicFunctionWeight.maxFunctionImportance),
            lessThanOrEqualTo(HarmonicFunctionWeight.maxFunctionImportance),
          ),
        ),
      );
    }
  });

  test('Harmonic Bank Error', () {
    // This could happen when prog was 'I 4, iii 4, IV 4, V 4, vi 2, IV 2, II 4, V 4, I 4'
    // and we used KeepHarmonicFunction.low with the default bank.

    var base = DegreeProgression.parse(
        'I 4, iii, iiø/iii, V/iii, iii, IV 4, V 4, vi 2, ii°/II 2, V/II 2, II 2, V 4, I 4');
    var prog = DegreeProgression.parse(
        'I 4, iii, iiø/iii, bII/IV, V/IV, IV 4, V 4, vi 2, ii°/II 2, V/II 2, II 2, V 4, I 4');

    expect(
      () => const HarmonicFunctionWeight().score(progression: prog, base: base),
      returnsNormally,
    );
  });
}
