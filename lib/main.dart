// ignore_for_file: avoid_print

import 'package:tonic/tonic.dart';

import 'modals/chord_progression.dart';
import 'modals/pitch_scale.dart';
import 'modals/scale_degree_progression.dart';
import 'modals/substitution.dart';
import 'modals/weights/keep_harmonic_function_weight.dart';
import 'state/progression_bank.dart';
import 'state/substitution_handler.dart';

void main() {
  ProgressionBank.initializeBuiltIn();
  _testCut();
  _test();
}

_test() {
  // Chords for "יונתן הקטן".
  ChordProgression base = ChordProgression(
    chords: [
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('Dm'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
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
  );
  // SubstitutionHandler.test(
  //   base: base,
  //   bank: bank,
  // );

  ScaleDegreeProgression progression = ScaleDegreeProgression.fromChords(
      PitchScale.common(tonic: Pitch.parse('C')), base);
  List<Substitution> subs = SubstitutionHandler.getRatedSubstitutions(
      progression,
      keepAmount: KeepHarmonicFunctionAmount.low);
  print('subs (low): ${subs.length}');
  assert(subs.length >= 1128);

  subs = SubstitutionHandler.getRatedSubstitutions(progression,
      keepAmount: KeepHarmonicFunctionAmount.med);
  print('subs (medium): ${subs.length}');
  assert(subs.length >= 1128);

  subs = SubstitutionHandler.getRatedSubstitutions(progression,
      keepAmount: KeepHarmonicFunctionAmount.high);
  print('subs (high): ${subs.length}');
  assert(subs.length >= 32);
}

_testCut() {
  var base = ScaleDegreeProgression.fromList(
      [null, null, 'V', 'V', null, null, 'I', null]);
  var sub = ScaleDegreeProgression.fromList(['ii', 'V', 'I', 'ii']);
  print(base);
  print(sub);
  int start = 0;
  double startDur = 0.25;
  int? end = 3;
  double? endDur = 0.25;
  print(base.getFittingMatchLocations(
    sub,
    start: start,
    startDur: startDur,
    end: end,
    endDur: endDur,
  ));

  List<Substitution> subs = base.getPossibleSubstitutions(
    sub,
    start: start,
    startDur: startDur,
    end: end,
    endDur: endDur,
  );

  for (Substitution sub in subs) {
    print('${sub.substitutedBase} - ${sub.match}');
    print('${sub.substitutedBase.durations}\n');
  }
}
