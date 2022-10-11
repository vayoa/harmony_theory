import 'package:harmony_theory/modals/progression/chord_progression.dart';
import 'package:harmony_theory/modals/progression/degree_progression.dart';
import 'package:harmony_theory/modals/theory_base/pitch_scale.dart';
import 'package:harmony_theory/modals/weights/weight.dart';
import 'package:test/test.dart';

abstract class TestUtils {
  /// Parses either a DegreeProgression or a [ChordProgression]
  /// in the C Major scale (and converts it to a [DegreeProgression]).
  static DegreeProgression parse(String input) {
    try {
      return DegreeProgression.parse(input);
    } catch (e) {
      return DegreeProgression.fromChords(
          PitchScale.cMajor, ChordProgression.parse(input));
    }
  }
}

/// An extension on the [Weight] class with common functions for
/// unit testing, to not be included in our release bundle.
extension WeightTests on Weight {
  /// Parses [in1] and [in2] with [TestUtils.parse], then
  /// expects [n1] to have a lower score than [n2].
  ///
  /// If [fails] is true we expect the previous condition to fail.
  scoredLess(String in1, String in2, {bool fails = false}) {
    final p1 = TestUtils.parse(in1);
    final p2 = TestUtils.parse(in2);
    final r1 = score(progression: p2, base: p2);
    final r2 = score(progression: p1, base: p1);
    var e = lessThan(r1.score);
    if (fails) e = isNot(e);
    return expect(
      r2.score,
      e,
      reason: "P1 Details:\n$r1"
          "\n-------------------------------------------"
          "\nP2 Details:\n$r2",
    );
  }

  specific(String input, dynamic matcher) {
    final p = TestUtils.parse(input);
    final r = score(base: p, progression: p);
    return expect(r.score, matcher, reason: 'Score Details:\n${r.details}');
  }
}
