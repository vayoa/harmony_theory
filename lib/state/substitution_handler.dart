import 'dart:io';

import 'package:thoery_test/modals/chord_progression.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution.dart';
import 'package:thoery_test/modals/weights/climactic_ending_weight.dart';
import 'package:thoery_test/modals/weights/complex_weight.dart';
import 'package:thoery_test/modals/weights/harmonic_function_weight.dart';
import 'package:thoery_test/modals/weights/important_chords_weight.dart';
import 'package:thoery_test/modals/weights/in_scale_weight.dart';
import 'package:thoery_test/modals/weights/keep_harmonic_function_weight.dart';
import 'package:thoery_test/modals/weights/overtaking_weight.dart';
import 'package:thoery_test/modals/weights/rhythm_and_placement_weight.dart';
import 'package:thoery_test/modals/weights/uniques_weight.dart';
import 'package:thoery_test/modals/weights/user_saved_weight.dart';
import 'package:thoery_test/modals/weights/weight.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:tonic/tonic.dart';

import '../modals/pitch_scale.dart';

abstract class SubstitutionHandler {
  static List<Weight> weights = [
    const InScaleWeight(),
    const OvertakingWeight(),
    const UniquesWeight(),
    const HarmonicFunctionWeight(),
    const RhythmAndPlacementWeight(),
    const ImportantChordsWeight(),
    const ClimacticEndingWeight(),
    const UserSavedWeight(),
    const ComplexWeight(),
  ]..sort(
      (Weight w1, Weight w2) => -1 * w1.importance.compareTo(w2.importance));

  static const KeepHarmonicFunctionWeight keepHarmonicFunction =
      KeepHarmonicFunctionWeight();

  static KeepHarmonicFunctionAmount keepAmount = KeepHarmonicFunctionAmount.med;

  static final Map<String, Weight> weightsMap = {
    for (Weight weight in weights) weight.name: weight
  };

  static ChordProgression inputChords() {
    ChordProgression _chords = ChordProgression.empty();
    // ignore: avoid_print
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
          // ignore: avoid_print
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
    Sound? sound,
    KeepHarmonicFunctionAmount? keepAmount,
    ScaleDegreeProgression? harmonicFunctionBase,
    int start = 0,
    double startDur = 0.0,
    int? end,
    double? endDur,
  }) {
    if (keepAmount != null) SubstitutionHandler.keepAmount = keepAmount;
    List<Substitution> substitutions = _getPossibleSubstitutions(
      base,
      start: start,
      startDur: startDur,
      end: end,
      endDur: endDur,
    );
    List<Substitution> sorted = [];
    bool shouldCalc = keepAmount != KeepHarmonicFunctionAmount.low;
    for (Substitution sub in substitutions) {
      SubstitutionScore? score = sub.scoreWith(
        weights,
        keepHarmonicFunction: shouldCalc,
        sound: sound,
        harmonicFunctionBase: harmonicFunctionBase,
      );
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
    // ignore: avoid_print
    print('Your Progression:\n$base.');

    // Detect the base progressions' scale
    scale ??= base.krumhanslSchmucklerScales.first;
    // ignore: avoid_print
    print('Scale Found: $scale.');

    // Convert the base progression to roman numerals, we used the most probable
    // scale that was detected (which would be the first in the list).
    final ScaleDegreeProgression baseProgression =
        ScaleDegreeProgression.fromChords(scale, base);
    // ignore: avoid_print
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

    // ignore: avoid_print
    print('Suggestions:');
    String subs = '';
    for (Substitution sub in rated) {
      subs += '${sub.toString(scale: scale)}\n\n';
    }
    // ignore: avoid_print
    print(subs);
    return rated;
  }

  /// Substitutes the best option for [maxIterations] iterations.
  static Substitution substituteBy({
    required ScaleDegreeProgression base,
    required int maxIterations,
    Sound? sound,
    KeepHarmonicFunctionAmount? keepHarmonicFunction,
    int start = 0,
    double startDur = 0.0,
    int? end,
    double? endDur,
  }) {
    ScaleDegreeProgression prev = base;
    List<Substitution> rated;
    do {
      rated = getRatedSubstitutions(
        prev,
        sound: sound,
        keepAmount: keepHarmonicFunction,
        harmonicFunctionBase: base,
        start: start,
        startDur: startDur,
        end: end,
        endDur: endDur,
      );
      prev = rated.first.substitutedBase;
      maxIterations--;
    } while (maxIterations > 0);
    Substitution result = rated.first.copyWith(base: base);
    return result;
  }

  static Substitution perfectSubstitution({
    required ChordProgression base,
    int? maxIterations,
    Sound? sound,
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
        sound: sound,
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
    return result;
  }
}
