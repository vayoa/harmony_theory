import 'package:harmony_theory/modals/weights/bass_movement_weight.dart';
import 'package:test/test.dart';

import '../utilities.dart';

const weight = BassMovementWeight();

main() {
  group('.score()', () {
    test('specific', () {
      weight.specific("F 2, C7/Bb, F/A, E 4", lessThan(1.0));
      weight.specific(
          "Am 4, E 4, F 4, D 4, G 2, Bm7, E7, Am7 2, B7 2, Am/E 4, E7 4", 1.0);
      weight.specific(
          "Am 4, E 4, F 4, Gm 2, D 2, G 2, E7/G# 2, Am7 2, B7 2, Am/E 4, E7 4",
          1.0);
      weight.specific(
          "Am 2, D 2, Bdim 2, E, E7, A7, A7/G, D/F#, D, G 2, E, E7, Am 4", 1.0);
    });
  });
}
