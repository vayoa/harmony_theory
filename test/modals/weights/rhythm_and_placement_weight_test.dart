import 'package:harmony_theory/modals/weights/rhythm_and_placement_weight.dart';
import 'package:test/test.dart';

import '../utilities.dart';

const weight = RhythmAndPlacementWeight();

main() {
  test('.score()', () {
    // TODO: FIX!!
    weight.specific("Am 4, E 4, F 4, D 4, G 2, E7/G# 2, Am7 2, B7 2, B 4, E7 4",
        lessThan(1.0));
  });
}
