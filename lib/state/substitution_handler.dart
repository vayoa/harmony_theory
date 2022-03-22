import 'dart:io';
import 'package:thoery_test/extensions/scale_extension.dart';
import 'package:thoery_test/modals/chord_progression.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution.dart';
import 'package:thoery_test/modals/weights/harmonic_function_weight.dart';
import 'package:thoery_test/modals/weights/important_chords_weight.dart';
import 'package:thoery_test/modals/weights/in_scale_weight.dart';
import 'package:thoery_test/modals/weights/keep_harmonic_function_weight.dart';
import 'package:thoery_test/modals/weights/new_rhythm_weight.dart';
import 'package:thoery_test/modals/weights/overtaking_weight.dart';
import 'package:thoery_test/modals/weights/rhythm_weight.dart';
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
    // RhythmWeight(),
    ImportantChordsWeight(),
    NewRhythmWeight(),
  ];

  static const KeepHarmonicFunctionWeight keepHarmonicFunction =
      KeepHarmonicFunctionWeight();

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
    required ProgressionBank bank,
    int start = 0,
    int? end,
  }) {
    final List<Substitution> substitutions = [];
    for (ScaleDegreeChord? chord in base.values) {
      if (chord != null) {
        // TODO: Implement tonicization optimization.
        List<ScaleDegreeProgression>? progressions =
            bank.getByGroup(chord, false);
        if (progressions != null && progressions.isNotEmpty) {
          for (ScaleDegreeProgression sub in progressions) {
            List<Substitution> possibleSubs =
                base.getPossibleSubstitutions(sub, start: start, end: end);
            for (Substitution possibleSub in possibleSubs) {
              if (possibleSub.substitutedBase != base) {
                substitutions.add(possibleSub);
              }
            }
          }
        }
      }
    }
    // TODO: Optimize...
    return substitutions.toSet().toList();
  }

  static List<Substitution> getRatedSubstitutions(
    ScaleDegreeProgression base, {
    required ProgressionBank bank,
    bool keepHarmonicFunction = false,
    ScaleDegreeProgression? harmonicFunctionBase,
    int start = 0,
    int? end,
  }) {
    List<Substitution> substitutions =
        _getPossibleSubstitutions(base, bank: bank, start: start, end: end);
    for (Substitution sub in substitutions) {
      sub.scoreWith(weights,
          keepHarmonicFunction: keepHarmonicFunction,
          harmonicFunctionBase: harmonicFunctionBase);
    }
    substitutions.sort((Substitution a, Substitution b) => -1 * a.compareTo(b));
    return substitutions;
  }

  static MapEntry<PitchScale, ScaleDegreeProgression> getAndPrintBase(
      ChordProgression base,
      {PitchScale? scale}) {
    print('Your Progression:\n$base.');

    // Detect the base progressions' scale
    scale ??= base.krumhanslSchmucklerScales.first;
    print('Scale Found: ${scale.commonName}.');

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
      keepHarmonicFunction = false,
      required ProgressionBank bank}) {
    assert(base != null || inputBase);
    if (inputBase) {
      base = inputChords();
    }
    var sAP = getAndPrintBase(base!);
    PitchScale scale = sAP.key;
    ScaleDegreeProgression baseProgression = sAP.value;

    List<Substitution> rated = getRatedSubstitutions(baseProgression,
        bank: bank, keepHarmonicFunction: keepHarmonicFunction);

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
    required ProgressionBank bank,
    required int maxIterations,
    bool keepHarmonicFunction = false,
    int start = 0,
    int? end,
    PitchScale? scale,
  }) {
    var sAP = getAndPrintBase(base, scale: scale);
    scale = sAP.key;
    ScaleDegreeProgression baseProgression = sAP.value, prev = baseProgression;
    List<Substitution> rated;
    do {
      rated = getRatedSubstitutions(
        prev,
        bank: bank,
        keepHarmonicFunction: keepHarmonicFunction,
        harmonicFunctionBase: baseProgression,
        start: start,
        end: end,
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
    required ProgressionBank bank,
    int? maxIterations,
    bool keepHarmonicFunction = false,
    int start = 0,
    int? end,
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
        bank: bank,
        keepHarmonicFunction: keepHarmonicFunction,
        harmonicFunctionBase: baseProgression,
        start: start,
        end: end,
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
