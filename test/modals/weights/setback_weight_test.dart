import 'package:harmony_theory/modals/weights/setback_weight.dart';
import 'package:test/test.dart';

import '../utilities.dart';

const OvertakingWeight weight = OvertakingWeight();

main() {
  group('.score()', () {
    test('specific', () {
      weight.specific("C 4, E 4, Am 4, C 4", 1.0);
      // Inversions aren't considered equal chords to their root equivalent
      // in this weight...
      weight.specific("F 4, E/B, B, E 2, Am 4, C 4", 1.0);
      weight.specific("F 2, C, F, E 4, Am 4, C 4", lessThan(0.8));
    });

    test('hierarchy', () {
      weight.scoredLess(
        "Em, F#m, B, Em, F 4, G 4",
        "Em, F#m, B, Am, F 4, G 4",
      );
      // AY: Should this be less?
      weight.scoredLess(
        "Em, F#m, B, Em, F 4, G 4",
        "Em 2, F#m, B, Em 2, F 2, G 4",
        fails: true,
      );
    });
  });
}
