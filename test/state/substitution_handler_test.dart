import 'package:harmony_theory/modals/pitch_chord.dart';
import 'package:harmony_theory/modals/progression/chord_progression.dart';
import 'package:harmony_theory/modals/progression/scale_degree_progression.dart';
import 'package:harmony_theory/modals/substitution.dart';
import 'package:harmony_theory/modals/theory_base/pitch_scale.dart';
import 'package:harmony_theory/modals/weights/keep_harmonic_function_weight.dart';
import 'package:harmony_theory/state/progression_bank.dart';
import 'package:harmony_theory/state/substitution_handler.dart';
import 'package:test/test.dart';
import 'package:tonic/tonic.dart';

main() {
  // First initialize the bank...
  setUp(() {
    ProgressionBank.initializeBuiltIn();
  });

  // Test...
  group('getRatedSubstitutions()', () {
    test('KeepHarmonicFunctionAmount.low', () {
      _testKeepHarmonicFunctionAmount(
        progression: _yonatanHakatan,
        amount: KeepHarmonicFunctionAmount.low,
        greaterThan: 1128,
        expectingToContain: _lowResults,
      );
    });
    test('KeepHarmonicFunctionAmount.med', () {
      _testKeepHarmonicFunctionAmount(
        progression: _yonatanHakatan,
        amount: KeepHarmonicFunctionAmount.med,
        greaterThan: 1128,
        expectingToContain: _lowResults,
      );
    });
    test('KeepHarmonicFunctionAmount.high', () {
      _testKeepHarmonicFunctionAmount(
        progression: _yonatanHakatan,
        amount: KeepHarmonicFunctionAmount.high,
        greaterThan: 26,
        expectingToContain: _highResults,
      );
    });
  });
}

_testKeepHarmonicFunctionAmount({
  required ScaleDegreeProgression progression,
  required KeepHarmonicFunctionAmount amount,
  required int greaterThan,
  required List<String> expectingToContain,
}) {
  List<Substitution> subs = SubstitutionHandler.getRatedSubstitutions(
    progression,
    keepAmount: amount,
  );
  expect(subs.length, greaterThanOrEqualTo(greaterThan));
  List<String> result = _getStrings(subs);
  expect(result, containsAll(expectingToContain));
}

List<String> _getStrings(List<Substitution> subs) =>
    [for (var sub in subs) sub.substitutedBase.toString()];

List<String> _getSplit(String str) => str.trim().split('\n');

final ScaleDegreeProgression _yonatanHakatan =
    ScaleDegreeProgression.fromChords(
        PitchScale.common(tonic: Pitch.parse('C')),
        ChordProgression(
          chords: [
            PitchChord.parse('C'),
            PitchChord.parse('G'),
            PitchChord.parse('C'),
            PitchChord.parse('G'),
            PitchChord.parse('C'),
            PitchChord.parse('G'),
            PitchChord.parse('C'),
            PitchChord.parse('G'),
            PitchChord.parse('C'),
            PitchChord.parse('Dm'),
            PitchChord.parse('G'),
            PitchChord.parse('C'),
            PitchChord.parse('G'),
            PitchChord.parse('C'),
            PitchChord.parse('G'),
            PitchChord.parse('C'),
            PitchChord.parse('G'),
            PitchChord.parse('C'),
          ],
          durations: [
            1 / 4 * 2,
            1 / 4 * 2,
            1 / 4 * 2,
            1 / 4 * 2,
            1 / 4 * 2,
            1 / 4 * 2,
            1 / 8 * 2,
            1 / 8 * 2,
            1 / 4 * 2,
            1 / 4 * 2,
            1 / 4 * 2,
            1 / 4 * 2,
            1 / 4 * 2,
            1 / 4 * 2,
            1 / 4 * 2,
            1 / 8 * 2,
            1 / 8 * 2,
            1 / 4 * 2,
          ],
        ));

final List<String> _lowResults = _getSplit(
    """| I, IV, II, V | III, vi, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, IV, II, V | III, vi, V | I, V, I |
| I, V | I, IV, II, V | III, vi, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii/V, V/V, V | I, V | I, V, I |
| I, ii/V, V/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, ii/ii | V/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, ii/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iiø/V, V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii°/V, V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iiø/V, V7/V, V | I, V | I, V, I |
| I, ii°/V, V/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, iiø/V, V/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, iiø/V, V7/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, iv/ii | V/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, ii°/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, iiø/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, iiø/V, V7/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, bVI/V | IV/V, bVII/V, V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bVII/V, vii°7/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iv/V, V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bVII/V, V/V, V | I, V | I, V, I |
| I, V, bVI/V | IV/V, bVII/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iiø/V, V7/V, V | I, V | I, V | I, V, I |
| I, V | I, bVII/V, vii°7/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, bVII/V, vii°7/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, ii/V, V/V, V | I, V | I, V | I, V, I |
| I, iv/V, V/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, iv/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, ii°/V, V/V, V | I, V | I, V | I, V, I |
| I, V | I, bVII/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, bVII/V, V/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iiø/V, V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | IV, II, V, III | vi, I, V | I, V | I, V, I |
| I, bVI, IV, bVII | V, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, iiø | V7, I, V | I, V | I, V, I |
| I, V, iiø | V7, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, ii/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iiø, V7 | I, V | I, V, I |
| I, V | IV, II, V, III | vi, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | IV, II, V, III | vi, I, V | I, V, I |
| I, V | I, V, iiø | V7, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, iiø | V7, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, IV, II, V | III, vi, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, iiø/ii | V/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, iiø/ii | V7/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, ii°/ii | V/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, iiø, V7 | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, bVI, IV, bVII | V, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bVI, IV, bVII | V, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, ii/V, V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I, IV/ii | V/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, IV | II, V, III, vi | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, iiø, V7, I | ii, V | I, V | I, V | I, V, I |
| I, iiø, V7 | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, ii°/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, iiø/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, iiø/V, V7/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bII/V, V/V, V | I, V | I, V, I |
| I, V | I, V | I, IV, II, V | III, vi, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, bII/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, bII/V, V/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iv/V, V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | ii/V, V/V, V | I, V | I, V, I |
| I, V | iv/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | iiø/V, V7/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | iiø/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | iv/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | iiø/V, V7/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | iv/V, V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | iiø/V, V7/V, V | I, V | I, V, I |
| I, V | ii°/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | iiø/V, V7/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | iiø/V, V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | iiø/V, V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | ii°/V, V/V, V | I, V | I, V, I |
| I, V | I, V | ii/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | ii/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | ii°/V, V/V, V | I, V, I |
| I, V | I, V | ii°/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | ii/V, V/V, V | I, V, I |
| I, V | I, V | iiø/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | iv/V, V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iiø/V, V7/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, ii°/V, V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iiø/V, V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVI, IV, bVII | V, I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | bVI, IV, bVII, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, iiø, V7, I |
| I, V | bVI, IV, bVII, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, iiø/ii, V/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, iiø/ii, V7/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, ii°/ii, V/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, bVII/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, bVII/V, vii°7/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, iv/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V, bVI/V | IV/V, bVII/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, vi, III, V | II, IV, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V, ii° | V, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, ii° | V, I, V | I, V | I, V, I |
| I, V, iiø | V, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, iiø | V, I, V | I, V | I, V, I |
| I, V | I, V | I, V, iv/V | V/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, iiø/V | V7/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, iiø/V | V/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, ii°/V | V/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, ii/V | V/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, iiø, V7 | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVI/V, bVII/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii/V | V/V, V | I, V, I |
| I, V | I, ii/V | V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, ii/V | V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVI/V, IV/V | bVII/V, V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, IV, I, V | I, V | I, V, I |
| I, V | I, V, iiø | V, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, iiø | V, I, V | I, V, I |
| I, V | I, V, ii° | V, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, ii° | V, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bVII/V, vii°7/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iv/V, V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bVII/V, V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, bVI/V | IV/V, bVII/V, V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, IV, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iv, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii°, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iiø, V7 | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, ii/V | V/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, ii°/V | V/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, iiø/V | V/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, iiø/V | V7/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, iv/V | V/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iiø, V | I, V | I, V, I |
| I, IV, I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, IV, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, IV | I, ii, V | I, V | I, V | I, V, I |
| I, V, bVI | bVII, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, bVI | bVII, I, V | I, V | I, V, I |
| I, V | I, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, iv, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, IV, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, ii°, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, iiø, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, vi, III, V | II, IV, V | I, V, I |
| I, V | I, vi, III, V | II, IV, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, iv/ii, V/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, ii/ii, V/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bVI/V, bVII/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii/V, bII/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, bVI | bVII, I, V | I, V, I |
| I, V | I, V, bVI | bVII, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, iiø, V7, I | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iiø, V7, I | I, V, I |
| I, V | I, V | IV, II, V, III | vi, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, I | IV, I, V | I, V | I, V, I |
| I, V | I, V | I, V, bVI | IV, bVII, V, I | ii, V | I, V | I, V | I, V, I |
| I, V, I | IV, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, ii/V, bII/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, bII/ii | V/ii, ii, V | I, V | I, V | I, V, I |
| I, bVI/V, bVII/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, ii/ii | bII/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, ii/V, bII/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, bVI/V, bVII/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, bVI/ii, IV/ii, bVII/ii | V/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bII/V, V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, bVI/V | IV/V, bVII/V, V/V, V | I, V | I, V | I, V, I |
| I, iv, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, bVII/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii/V, V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, iv, V, I | ii, V | I, V | I, V | I, V, I |
| I, ii°, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, iiø, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, IV, V, I | ii, V | I, V | I, V | I, V, I |
| I, IV, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, iiø, V, I | ii, V | I, V | I, V | I, V, I |
| I, V/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, ii°, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iv, I, V | I, V | I, V, I |
| I, bVI/V, IV/V | bVII/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, iv/V, V | I, V | I, V, I |
| I, V | I, V, I | IV, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, I | IV, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iiø/V | V/V, V | I, V, I |
| I, ii°/V | V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, iiø/V | V7/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iiø/V | V7/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii°/V | V/V, V | I, V, I |
| I, V | I, iiø/V | V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, iiø/V | V7/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, iiø/V | V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, ii°/V | V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V+/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, vii°7/V, V | I, V | I, V, I |
| I, iiø, V7, I | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, iv, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, IV/V, V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, bVI/ii | bVII/ii, ii, V | I, V | I, V | I, V, I |
| I, V, iv/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V, iv/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, ii | iv/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, iv/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, iv | I, ii, V | I, V | I, V | I, V, I |
| I, iv, I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | IV, II, V, III | vi, V, I |
| I, V | I, bVI/V, IV/V | bVII/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bVI/V, IV/V | bVII/V, V/V, V | I, V, I |
| I, IV | II, V | III, vi | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V+/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, vii°7/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, bVII/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bVII/V, V | I, V | I, V, I |
| I, V | I, V | I, bVII/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V/V, V | I, V | I, V, I |
| I, V | I, V | I, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bVII/V, V | I, V, I |
| I, V | I, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, bII/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iiø, V7 | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii°/V, bII/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, vi, III, V | II, IV, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, I, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, iv | V, I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, I | iv, I, V | I, V | I, V, I |
| I, V, I | iv, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V, iv | V, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V, IV | V, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, IV | V, I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iiø, V7, I | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, iv, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, ii°, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, iiø, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, IV, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bVI, bVII | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bVII, vii°7 | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVII/V, V/V, V | I, V | I, V | I, V, I |
| I, V | I, V, bVI | IV, bVII, V, I | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, bVI | IV, bVII, V, I | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, bVI | IV, bVII, V, I |
| I, V | I, ii°/V, bII/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, ii°/V, bII/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVII/V, vii°7/V, V | I, V | I, V | I, V, I |
| I, V+/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V+/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | iiø/V, V/V, V | I, V | I, V | I, V, I |
| I, vii°7/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii°/V, V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, V/ii | ii, V | I, V | I, V | I, V, I |
| I, vii°7/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | iiø/V, V7/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | V/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V, IV | V, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V, iv | V, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bII/V, V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, iv | V, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, I | iv, I, V | I, V, I |
| I, V | I, V, I | iv, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, IV | V, I, V | I, V, I |
| I, V | I, iiø, V7, I | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, bVI, bVII | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, bVII, vii°7 | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | bVI, IV, bVII, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | bII/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | bII/V, V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | bII/V, V/V, V | I, V, I |
| I, V | I, V | bII/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, bVII/V | V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iiø/V | V7/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bVII/V | vii°7/V, V | I, V, I |
| I, bVII/V | vii°7/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | iiø, V7 | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iv/V | V/V, V | I, V, I |
| I, V | I, bVII/V | vii°7/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, ii/V | V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | iiø, V7, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bVII/V | V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, ii°/V | V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iiø/V | V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | iiø, V7 | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | iiø, V7, I |
| I, iv/V | V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, iv/V | V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, bVII/V | V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, IV, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, iv, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, ii°, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, iiø, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, IV/V | V/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, IV/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | vi, III, V, II | IV, I, V | I, V, I |
| I, V | vi, III, V, II | IV, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, vii°7/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V+/V, V | I, V, I |
| I, V | I, V+/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V+/V, V | I, V | I, V, I |
| I, V | I, V | I, V+/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, vii°7/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, vii°7/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, vii°7/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, bVI, bVII, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, IV/V | V/V, V, I |
| I, bVI, bVII | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, bVII, vii°7 | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iv, V | I, V, I |
| I, V | I, V | I, V | I, V, bII/ii, V/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, IV, V | I, V, I |
| I, V | I, V | I, V | I, bVII, vii°7, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, ii°, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iiø, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, bVI | IV, bVII, V, I | I, V | I, V, I |
| I, V | I, V, IV/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V, IV/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | bVI, IV, bVII, V | I, V, I |
| I, V | I, V | I, V | I, V, I, ii | IV/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, IV, iv | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, ii/V, bII/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | bVI, IV, bVII, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, ii°/V, bII/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, bVI/V, IV/V | bVII/V, V/V, V | I, V | I, V | I, V, I |
| I, V, bVI | IV, bVII, V, I | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, ii, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, IV, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, bII/V | V/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | iv/V, V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | bVII/V, V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, V+/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | bVII/V, vii°7/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | V+/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, bVI/V, IV/V, bVII/V | V/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, IV, iv | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, iv, V, I | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | bVII/V, vii°7/V, V | I, V, I |
| I, V | bVII/V, V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | bVII/V, vii°7/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | bVII/V, V/V, V | I, V | I, V, I |
| I, V | bVI/V, bVII/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, IV, V, I | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iiø, V, I | I, V, I |
| I, V | I, V | bVII/V, V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | bVII/V, vii°7/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | bVI/V, bVII/V, V | I, V, I |
| I, V | bVII/V, vii°7/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | bVI/V, bVII/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, IV, V, I | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, iiø, V, I | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, ii°, V, I | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | bVI/V, bVII/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iv, V, I | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | bVII/V, V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, ii°, V, I | I, V, I |
| I, V | I, V | I, V | I, V, I | vii°7/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, bVII/ii, vii°7/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, IV/ii | iv/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, bII/V | V/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, vi | I, V | I, V, I |
| I, V, bVII | vii°7, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, bVII | vii°7, I, V | I, V | I, V, I |
| I, V | I, V | I, V, vi | III, V, II, IV | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, vii°7/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V+/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, IV, I, V | I, V, I |
| I, V | I, V | I, V | I, ii, V, I | ii, V | I, V | I, V | I, V, I |
| I, ii, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, bVII, vii°7, I |
| I, V | I, V | I, ii/V, bII/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, bVI/V, bVII/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V, vi | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, bVI, IV | bVII, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, bVII | vii°7, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bVI/V, IV/V, bVII/V | V/V, V, I |
| I, V | I, V, bVII | vii°7, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, IV, iv, I | ii, V | I, V | I, V | I, V, I |
| I, IV, iv | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, vii°7/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V+/V, V | I, V, I |
| I, iv, V, I | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, iiø, V, I | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, IV, V, I | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, ii°, V, I | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, ii°/ii | bII/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bVI, IV | bVII, V, I |
| I, V | I, V | I, V, iv/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, iv, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, bVII, vii°7 | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, bVII/V | V/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, bVII/V | vii°7/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, bVI, bVII | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, bVI/V | bVII/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, ii/V, bII/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bVI/V, bVII/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | iv/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, iv/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, ii°, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, vi | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, vi, I | ii, V | I, V | I, V | I, V, I |
| I, V, vi | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iiø, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, IV, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, ii | V, I, V | I, V | I, V, I |
| I, V, ii | V, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, ii, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii°, V, I | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, IV, V, I | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iv, V, I | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iiø, V, I | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, bVII/V | V/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bVII, vii°7 | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iv/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii°/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, V+ | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, bVII/V | vii°7/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, bVI/V | bVII/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bVI, bVII | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iiø/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bVII, V | I, V | I, V, I |
| I, V, IV | iv, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, IV | iv, I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iiø, V7, I | I, V | I, V | I, V, I |
| I, bII/V | V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iv/V | V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bII/V | V/V, V | I, V, I |
| I, V | I, bII/V | V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V, ii | V, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, ii | V, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, iv/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iv, I, V | I, V, I |
| I, V | I, V | I, ii°/V, bII/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bII, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, ii° | bII, I, V | I, V | I, V, I |
| I, V, ii° | bII, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, iv, V, I | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, ii°, V, I | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, iiø, V, I | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, IV, V, I | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, iiø/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, bVII, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, iv/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, ii°/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V, V+ | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, IV | iv, I, V | I, V, I |
| I, V | I, V, IV | iv, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | vi, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | vi, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | vi, I, V | I, V | I, V, I |
| I, V | I, V | vi, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | vi, III, V, II | IV, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVII, vii°7 | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVI, bVII | I, V | I, V | I, V, I |
| I, V | I, bII, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, V/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, V/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, ii°/V | V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | iiø, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | iiø, V7 | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, iv/V | V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | ii°, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, iiø/V | V7/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | ii°, V, I |
| I, V | I, V | I, V | ii°, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | iiø, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | ii°, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, ii/V | V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | V/V, V | I, V, I |
| I, V | I, V | I, V | I, V, iiø/V | V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | V/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | V/V, V, I |
| I, V | I, V | V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | iiø, V, I |
| I, V | iiø, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | V/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V, ii° | bII, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, ii° | bII, I, V | I, V, I |
| I, V | I, V | I, ii, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | vi, III, V, II | IV, I, V | I, V | I, V, I |
| I, V, bII | V, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, bII | V, I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, ii°/V, bII/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVI/V | IV/V, bVII/V | V/V, V | I, V, I |
| I, V | I, V | I, IV, iv | I, V, I | ii, V | I, V | I, V | I, V, I |
| IV/V, iv/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, ii°/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, ii°/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, bVII, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V, V+ | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V+/V, V | I, V | I, V | I, V, I |
| I, iiø/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, iiø/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, V+, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | bII/V, V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, ii, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii°, bII | I, V | I, V, I |
| I, iv/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, V+ | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, bVII, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V+/V, V | I, V | I, V | I, V, I |
| I, V | I, V, bII | V, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, bII | V, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | vi, III, V, II | IV, V, I |
| I, V | I, V | I, V | I, iv, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | ii/V, bII/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | ii/V, bII/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | ii/V, bII/V, V | I, V, I |
| I, V | ii/V, bII/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | ii°/V, bII/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | ii°/V, bII/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | ii°/V, bII/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | ii°/V, bII/V, V | I, V, I |
| I, V | I, V | I, V, IV/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, ii° | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, IV | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, IV, iv | I, V, I |
| I, bII, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, vii°7 | I, V | I, V, I |
| I, V | I, V | I, V | I, bII, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, iiø | I, V | I, V, I |
| I, V | I, ii°, bII | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | bVI, bVII | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | bVI, bVII, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVI/V | bVII/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | bVI, bVII | I, V | I, V, I |
| I, V | I, V | I, V, vi | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, bVI | IV, bVII, V, I | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bII7/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | IV/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, IV/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V, ii° | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V, iiø | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V, IV | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V, vii°7 | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii°/V, V | I, V | I, V, I |
| I, V | I, V | I, ii°/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, ii°/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iiø/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iiø/V, V | I, V | I, V, I |
| I, V | I, V | I, iiø/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, iiø/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, ii, V, I | I, V, I |
| I, V | V+, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | V+, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, ii, V, I | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | V+, I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | V+, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, ii°/V, V | I, V, I |
| I, V, bVII | V, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, bVII | V, I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, vi | I, V, I |
| I, V | I, V | I, V | I, V, ii°/ii, bII/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, bII7/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, IV/V, V | I, V, I |
| I, V | I, V | vi, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | vii°7/V, V, I |
| I, V | I, V | I, V | vi, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | vii°7/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | V+/V, V | I, V, I |
| I, V | I, V | I, V | I, IV, I | ii, V | I, V | I, V | I, V, I |
| I, V | V+/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, IV | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | V+/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, vii°7 | I, V | I, V, I |
| I, V | I, V | I, V | I, V, V+/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | vi, V, I |
| I, V | I, V | I, V | V+/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V+ | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | vii°7/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V+, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, IV | I, V | I, V, I |
| I, V | vi, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | V+/V, V, I |
| I, V | I, V | I, V | I, vii°7, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | vi, V | I, V, I |
| I, V | I, V | I, V | vii°7/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | vii°7/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, vii°7 | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | vi, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, vii°7, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V+ | I, V | I, V, I |
| I, V | I, V | V+/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V+ | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | vii°7/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, IV | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, vii°7 | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, bVII, V, I |
| I, ii°, bII | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, ii°, bII, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V, bVII | V, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, bVII | V, I, V | I, V, I |
| I, V | I, V | I, V, ii°/V | bII/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, ii/V | bII/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, bVI/V | IV/V, bVII/V | V/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V, vii°7 | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, iiø, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, IV, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, IV | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, bII, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVII/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, ii°, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, ii° | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, vii°7 | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, vii°7/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, ii°/V, V | I, V | I, V | I, V, I |
| I, V, iiø | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, vii°7/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, ii°/V, V | I, V | I, V | I, V, I |
| I, V, ii° | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V, IV | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iiø/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iiø/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, iiø | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, IV, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, vii°7, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, IV/V, iv/V, V | I, V | I, V | I, V, I |
| I, ii, V, I | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, bII7/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, bII7/V, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, iv | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, ii°/V | bII/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, bVII | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, ii/V | bII/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, bII, I, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, IV, I | I, V, I |
| I, V | I, V | I, iiø/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, ii°/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, iv/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, V+ | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, bVII, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii/V | bII/V, V | I, V, I |
| I, V | I, ii/V | bII/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bVI/V | bVII/V, V | I, V, I |
| I, V | I, bVI/V | bVII/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, bVI/V | bVII/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bII/V | V/V, V | I, V | I, V, I |
| I, ii/V | bII/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | IV, I, V | I, V | I, V | I, V, I |
| I, V | I, V, bVII | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V, iv | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, vi, III, V | II, IV, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, bII, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | IV, I, V | I, V, I |
| I, V | vii°7, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | IV, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | vii°7, I, V | I, V | I, V, I |
| I, V | ii°, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | ii°, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | IV/V, iv/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | IV, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | iiø, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | IV/V, iv/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | IV, I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | ii°, I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | vii°7, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | ii°, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | IV/V, iv/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | IV/V, iv/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | iiø, I, V | I, V | I, V, I |
| I, V | I, V | vii°7, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | iiø, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | iiø, I, V | I, V, I |
| I, V | I, V | I, IV, I | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, IV | II, V | III, vi | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii, V, I | I, V | I, V, I |
| I, V | I, V | I, V | I, V, ii/ii, bII/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | bVI/ii, IV/ii, bVII/ii, V/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, V+ | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, ii°/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iv/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bVII, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iiø/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | I, V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iiø, V, I | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, ii°, V, I | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | I, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bII7/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bII7/V, V | I, V | I, V, I |
| I, V | I, bII7/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, bII7/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bII, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, vii°7, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | iv/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | bVII/V, V | I, V, I |
| I, V | I, V | I, V | I, iv, I | ii, V | I, V | I, V | I, V, I |
| I, V | iv, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, bVII | I, V | I, V, I |
| I, iv | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | IV, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, IV/V | V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | IV, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | iv, V, I |
| I, V | I, bVII | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | iv/V, V | I, V | I, V, I |
| I, V | I, V | I, V | IV, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iv | I, V | I, V, I |
| I, V | I, V | iv/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, bVII | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | bVII/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | iv, V | I, V | I, V, I |
| I, V | I, V | I, V | iv/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, vii°7 | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | iv/V, V | I, V, I |
| I, V | I, V | I, V | I, bVII, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | iv, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V+ | I, V | I, V | I, V, I |
| I, V | I, iv | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | IV, V | I, V | I, V, I |
| I, V | iv/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, ii, V, I | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, vii°7/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, iiø/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, ii, iv/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iv/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, I, IV | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, bVII | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | bVI/V, bVII/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii/V, bII/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iv, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVII, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii°/ii, ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I, ii°/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, iv | I, V | I, V | I, V, I |
| I, V, bVII | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, iv, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | iiø/ii, ii, V | I, V | I, V | I, V, I |
| I, V, iv | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, iv/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, bVI/ii, bVII/ii | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, ii°, bII | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, bVII, V, I | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bVII, V, I | I, V, I |
| I, V | I, V | I, V | I, V, I | ii°, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | iiø, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | iv, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | IV, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, vii°7 | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, ii° | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, iiø | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, IV | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, IV/V | iv/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, bII, V, I | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bII, V, I | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, iv, I | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, bII7 | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, ii°, bII | I, V, I |
| I, V | I, V | I, V | I, V, I | V, iv/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | iv, I, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii, bII | I, V | I, V, I |
| I, ii°/V | bII/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, ii°/V | bII/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVII/V | V/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii°/V | bII/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVII/V | vii°7/V, V | I, V | I, V, I |
| I, V | I, V | I, bII7/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | bVII, I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | iv, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | iv, I, V | I, V | I, V, I |
| I, V | I, V | iv, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | iv, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | bVII, I, V | I, V, I |
| I, V | I, V | bVII, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | bVII, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, iiø | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, IV/V | iv/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, vii°7 | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, ii° | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, IV | I, V, I |
| I, V | I, V, bII7 | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, iv, I | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, bVII, V, I | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, ii, bII | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, bII7/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, I | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, I | I, V, I |
| I, V | I, iiø | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | ii°/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | iiø/V, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, iiø | I, V | I, V, I |
| I, V | I, V | I, V | I, iiø, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | iiø/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | iiø/V, V | I, V, I |
| I, V | I, V | iiø/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | iiø/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | ii°/V, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, ii° | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | iiø/V, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | ii°/V, V | I, V | I, V, I |
| I, iiø | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | ii°/V, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, ii°, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, bII/V | V/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | ii°/V, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, ii° | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | ii°/V, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, ii° | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, bII, V, I | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, IV, II, V | III, vi, I |
| I, V | I, V | I, V | I, V, I | ii, I, iv | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii°/V, bII/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, IV | II, V | III, vi | I, V | I, V, I |
| I, V | I, V | I, V, I | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bII7/V, V | I, V | I, V | I, V, I |
| I, V, bII7 | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bII7/V, V | I, V | I, V | I, V, I |""");
final List<String> _highResults = _getSplit(
    """| I, V | I, V | I, V | I, V, vi, I | ii, V | I, V | I, V | I, V, I |
| I, V | vi, I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | vi, I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | vi, I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | vi, I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | iiø, V7 | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V, vii°7 | I, V | I, V, I |
| I, V | I, V, vii°7 | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, vii°7 | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, vii°7 | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, vii°7, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, vii°7 | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, vii°7, I |
| I, V, vii°7 | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V, vii°7 | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, bVII/V, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, vii°7 | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii°, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | iiø, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | IV, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | iv, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V, vii°7 | I, V, I | ii, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V, vii°7 | I, V, I |
| I, V | I, V | I, V | I, V, I | bVII, vii°7 | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | bVII, V | I, V | I, V | I, V, I |
| I, V | I, V | I, V | I, V, I | ii, V | I, V | I, V | I, V, vi, I |""");
