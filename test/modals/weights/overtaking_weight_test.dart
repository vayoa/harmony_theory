import 'package:harmony_theory/modals/progression/chord_progression.dart';
import 'package:harmony_theory/modals/progression/degree_progression.dart';
import 'package:harmony_theory/modals/theory_base/pitch_scale.dart';
import 'package:harmony_theory/modals/weights/overtaking_weight.dart';
import 'package:test/test.dart';

const OvertakingWeight weight = OvertakingWeight();

main() {
  group('.score()', () {
    test('specific', () {
      final p = _parse("C 4, E 4, Am 4, C 4");
      expect(weight.score(progression: p, base: p).score, equals(1.0));
    });

    test('hierarchy', () {
      _scoredLess(
        "Em, F#m, B, Em, F 4, G 4",
        "Em, F#m, B, Am, F 4, G 4",
      );
      // AY: Should this be less?
      _scoredLess(
        "Em, F#m, B, Em, F 4, G 4",
        "Em 2, F#m, B, Em 2, F 2, G 4",
      );
    });
  });
}

_scoredLess(String in1, String in2) {
  final p1 = _parse(in1);
  final p2 = _parse(in2);
  return expect(
    weight.score(progression: p1, base: p1).score,
    lessThan(weight.score(progression: p2, base: p2).score),
  );
}

_parse(String input) {
  try {
    return DegreeProgression.parse(input);
  } catch (e) {
    return DegreeProgression.fromChords(
        PitchScale.cMajor, ChordProgression.parse(input));
  }
}
