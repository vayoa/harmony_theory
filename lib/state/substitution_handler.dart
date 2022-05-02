import 'dart:io';

import 'package:thoery_test/modals/chord_progression.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution.dart';
import 'package:thoery_test/modals/weights/harmonic_function_weight.dart';
import 'package:thoery_test/modals/weights/important_chords_weight.dart';
import 'package:thoery_test/modals/weights/in_scale_weight.dart';
import 'package:thoery_test/modals/weights/keep_harmonic_function_weight.dart';
import 'package:thoery_test/modals/weights/overtaking_weight.dart';
import 'package:thoery_test/modals/weights/rhythm_and_placement_weight.dart';
import 'package:thoery_test/modals/weights/uniques_weight.dart';
import 'package:thoery_test/modals/weights/weight.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:tonic/tonic.dart';

import '../modals/pitch_scale.dart';

abstract class SubstitutionHandler {
  static const List<Weight> weights = [
    InScaleWeight(),
    OvertakingWeight(),
    UniquesWeight(),
    HarmonicFunctionWeight(),
    RhythmAndPlacementWeight(),
    ImportantChordsWeight(),
  ];

  static const KeepHarmonicFunctionWeight keepHarmonicFunction =
      KeepHarmonicFunctionWeight();

  static KeepHarmonicFunctionAmount _keepAmount =
      KeepHarmonicFunctionAmount.med;

  static KeepHarmonicFunctionAmount get keepAmount => _keepAmount;

  /* TODO: Find a better way to access weights by name (or provide the weight
          object in SubstitutionScore. */
  static final Map<String, Weight> weightsMap = {
    for (Weight weight in weights) weight.name: weight
  };

  static ChordProgression inputChords() {
    ChordProgression _chords = ChordProgression.empty();
    print("Please enter your chords (enter 's' to stop and '-' for a rest):");
    String? input;
    do {
      input = stdin.readLineSync() ?? '';
      if (input == '-') {
        _chords.add(null, 1 / 4);
      } else {
        Chord _chord;
        try {
          _chord = Chord.parse(input);
          _chords.add(_chord, 1 / 4);
        } on FormatException catch (e) {
          print(e);
        }
      }
    } while (input != 's');
    return _chords;
  }

  static List<Substitution> _getPossibleSubstitutions(
    ScaleDegreeProgression base, {
    int start = 0,
    double startDur = 0.0,
    int? end,
    double? endDur,
  }) {
    final List<Substitution> substitutions = [];
    end ??= base.length;
    for (int i = start; i < end; i++) {
      ScaleDegreeChord? chord = base[i];
      if (chord != null) {
        List<List<dynamic>>? progressions =
            ProgressionBank.getByGroup(chord: chord, withTonicization: false);
        if (progressions != null && progressions.isNotEmpty) {
          for (List<dynamic> pair in progressions) {
            substitutions.addAll(base.getPossibleSubstitutions(
              pair[1],
              start: start,
              startDur: startDur,
              end: end,
              endDur: endDur,
              forIndex: i,
              substitutionTitle: pair[0],
            ));
          }
        }
      }
    }
    // We do this here since it's more efficient...
    List<List<dynamic>> tonicizations = ProgressionBank.tonicizations;
    for (List<dynamic> sub in tonicizations) {
      substitutions.addAll(base.getPossibleSubstitutions(
        sub[1],
        start: start,
        startDur: startDur,
        end: end,
        endDur: endDur,
        substitutionTitle: sub[0],
      ));
    }
    return substitutions.toSet().toList();
  }

  static List<Substitution> getRatedSubstitutions(
    ScaleDegreeProgression base, {
    KeepHarmonicFunctionAmount? keepAmount,
    ScaleDegreeProgression? harmonicFunctionBase,
    int start = 0,
    double startDur = 0.0,
    int? end,
    double? endDur,
  }) {
    if (keepAmount != null) _keepAmount = keepAmount;
    List<Substitution> substitutions = _getPossibleSubstitutions(
      base,
      start: start,
      startDur: startDur,
      end: end,
      endDur: endDur,
    );
    List<Substitution> sorted = [];
    bool shouldCalc = _keepAmount != KeepHarmonicFunctionAmount.low;
    for (Substitution sub in substitutions) {
      SubstitutionScore? score = sub.scoreWith(weights,
          keepHarmonicFunction: shouldCalc,
          harmonicFunctionBase: harmonicFunctionBase);
      if (score != null) {
        sorted.add(sub);
      }
    }
    sorted.sort((Substitution a, Substitution b) => -1 * a.compareTo(b));
    return sorted;
  }

  static MapEntry<PitchScale, ScaleDegreeProgression> getAndPrintBase(
      ChordProgression base,
      {PitchScale? scale}) {
    print('Your Progression:\n$base.');

    // Detect the base progressions' scale
    scale ??= base.krumhanslSchmucklerScales.first;
    print('Scale Found: $scale.');

    // Convert the base progression to roman numerals, we used the most probable
    // scale that was detected (which would be the first in the list).
    final ScaleDegreeProgression baseProgression =
        ScaleDegreeProgression.fromChords(scale, base);
    print('In Roman Numerals: $baseProgression.\n');
    return MapEntry(scale, baseProgression);
  }

  static List<Substitution> test(
      {ChordProgression? base,
      bool inputBase = false,
      KeepHarmonicFunctionAmount? keepAmount,
      required ProgressionBank bank}) {
    assert(base != null || inputBase);
    if (inputBase) {
      base = inputChords();
    }
    var sAP = getAndPrintBase(base!);
    PitchScale scale = sAP.key;
    ScaleDegreeProgression baseProgression = sAP.value;

    List<Substitution> rated =
        getRatedSubstitutions(baseProgression, keepAmount: keepAmount);

    print('Suggestions:');
    String subs = '';
    for (Substitution sub in rated) {
      subs += '${sub.toString(scale: scale)}\n\n';
    }
    print(subs);
    return rated;
  }

  static Substitution substituteBy({
    required ChordProgression base,
    required int maxIterations,
    KeepHarmonicFunctionAmount? keepHarmonicFunction,
    int start = 0,
    double startDur = 0.0,
    int? end,
    double? endDur,
    PitchScale? scale,
  }) {
    var sAP = getAndPrintBase(base, scale: scale);
    scale = sAP.key;
    ScaleDegreeProgression baseProgression = sAP.value, prev = baseProgression;
    List<Substitution> rated;
    do {
      rated = getRatedSubstitutions(
        prev,
        keepAmount: keepHarmonicFunction,
        harmonicFunctionBase: baseProgression,
        start: start,
        startDur: startDur,
        end: end,
        endDur: endDur,
      );
      prev = rated.first.substitutedBase;
      maxIterations--;
    } while (maxIterations > 0);
    Substitution result = rated.first.copyWith(base: baseProgression);
    print(result.toString(scale: scale));
    return result;
  }

  static Substitution perfectSubstitution({
    required ChordProgression base,
    int? maxIterations,
    KeepHarmonicFunctionAmount? keepHarmonicFunction,
    int start = 0,
    double startDur = 0.0,
    int? end,
    double? endDur,
    PitchScale? scale,
  }) {
    var sAP = getAndPrintBase(base, scale: scale);
    scale = sAP.key;
    ScaleDegreeProgression baseProgression = sAP.value, prev = baseProgression;
    List<Substitution> rated;
    bool again = true;
    do {
      rated = getRatedSubstitutions(
        prev,
        keepAmount: keepHarmonicFunction,
        harmonicFunctionBase: baseProgression,
        start: start,
        startDur: startDur,
        end: end,
        endDur: endDur,
      );
      prev = rated.first.substitutedBase;
      if (maxIterations != null) {
        maxIterations--;
        again = maxIterations > 0;
      }
    } while (again && rated.first.rating != 1.0);
    Substitution result = rated.first.copyWith(base: baseProgression);
    print(result.toString(scale: scale));
    return result;
  }
}
