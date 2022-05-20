// ignore_for_file: avoid_print

import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/keep_harmonic_function_weight.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:thoery_test/state/substitution_handler.dart';
import 'package:tonic/tonic.dart';

import 'extensions/scale_pattern_extension.dart';
import 'modals/chord_progression.dart';
import 'modals/scale_degree.dart';
import 'modals/scale_degree_chord.dart';
import 'modals/substitution.dart';

void main() {
  _testCut();
  _test();
  final ChordProgression _base = ChordProgression.evenTime([
    Chord.parse('Cm'),
    Chord.parse('D#dim'),
    Chord.parse('G#'),
    Chord.parse('Bdim'),
    Chord.parse('E'),
    Chord.parse('A'),
    Chord.parse('D'),
    Chord.parse('Em'),
    Chord.parse('Em'),
    Chord.parse('Dm'),
    Chord.parse('G'),
    Chord.parse('Cm'),
  ]);

  PitchScale scale = PitchScale(
      tonic: Pitch.parse('C'), pattern: ScalePatternExtension.minorKey);

  var b = ScaleDegreeProgression.fromChords(scale, _base);

  print(_base);
  print('$b\n');

  Pitch tonic = Pitch.parse('E');
  var eb = PitchScale(tonic: tonic, pattern: ScalePatternExtension.majorKey);

  print(ScaleDegreeChord(eb, Chord.parse('D#dim')));

  var degree = ScaleDegree.parse('VII');

  print(degree.inScale(eb));
}

_test() {
  ProgressionBank.initializeBuiltIn();
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
  assert(subs.length >= 452);

  subs = SubstitutionHandler.getRatedSubstitutions(progression,
      keepAmount: KeepHarmonicFunctionAmount.med);
  print('subs (medium): ${subs.length}');
  assert(subs.length >= 452);

  subs = SubstitutionHandler.getRatedSubstitutions(progression,
      keepAmount: KeepHarmonicFunctionAmount.high);
  print('subs (high): ${subs.length}');
  assert(subs.length >= 19);
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
