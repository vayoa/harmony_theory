import 'package:harmony_theory/modals/weights/bass_movement_weight.dart';
import 'package:test/test.dart';

import '../utilities.dart';

const weight = BassMovementWeight();

main() {
  group('.score()', () {
    test('specific', () {
      weight.specific("F 2, C7/Bb, F/A, E 4", lessThan(1.0));
    });
  });
}
