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
}
