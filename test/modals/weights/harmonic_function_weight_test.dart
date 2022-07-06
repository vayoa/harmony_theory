import 'package:harmony_theory/modals/weights/harmonic_function_weight.dart';
import 'package:test/test.dart';

main() {
  test('Harmonic Bank Assertions', () {
    Map<int, Map<int?, Map<int, int>>> sorted =
        HarmonicFunctionWeight.sortedFunctions;
    for (int k in sorted.keys) {
      for (int? k2 in sorted[k]!.keys) {
        expect(
          sorted[k]![k2]!.values,
          everyElement(
            allOf(
              greaterThanOrEqualTo(
                  -1 * HarmonicFunctionBank.maxFunctionImportance),
              lessThanOrEqualTo(HarmonicFunctionBank.maxFunctionImportance),
            ),
          ),
        );
      }
    }
  });
}
