import 'dart:io';
import 'package:thoery_test/extensions/scale_extension.dart';
import 'package:thoery_test/modals/chord_progression.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution.dart';
import 'package:thoery_test/modals/weights/harmonic_function_weight.dart';
import 'package:thoery_test/modals/weights/in_scale_weight.dart';
import 'package:thoery_test/modals/weights/overtaking_weight.dart';
import 'package:thoery_test/modals/weights/uniques_weight.dart';
import 'package:thoery_test/modals/weights/weight.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:tonic/tonic.dart';

abstract class SubstitutionHandler {
  static const List<Weight> weights = [
    InScaleWeight(),
    OvertakingWeight(),
    UniquesWeight(),
    HarmonicFunctionWeight(),
  ];

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

  static List<Substitution> getPossibleSubstitutions(
      ScaleDegreeProgression base, ProgressionBank bank) {
    final List<Substitution> substitutions = [];
    for (ScaleDegreeChord? chord in base.values) {
      if (chord != null) {
        // TODO: Implement tonicization optimization.
        List<ScaleDegreeProgression>? progressions =
            bank.getByGroup(chord, false);
        if (progressions != null && progressions.isNotEmpty) {
          for (ScaleDegreeProgression sub in progressions) {
            List<Substitution> possibleSubs =
                base.getPossibleSubstitutions(sub);
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
      ScaleDegreeProgression base, ProgressionBank bank) {
    List<Substitution> substitutions = getPossibleSubstitutions(base, bank);
    for (Substitution sub in substitutions) {
      sub.score(weights);
    }
    substitutions.sort(
        (Substitution a, Substitution b) => -1 * a.rating.compareTo(b.rating));
    return substitutions;
  }

  static MapEntry<Scale, ScaleDegreeProgression> getAndPrintBase(
      ChordProgression base) {
    print('Your Progression:\n$base.');

    // Detect the base progressions' scale
    final List<Scale> _possibleScales = base.matchWithScales();
    print('Scale Found: ${_possibleScales[0].getCommonName()}.');

    // Convert the base progression to roman numerals, we used the most probable
    // scale that was detected (which would be the first in the list).
    final ScaleDegreeProgression baseProgression =
        ScaleDegreeProgression.fromChords(_possibleScales[0], base);
    print('In Roman Numerals: $baseProgression.\n');
    return MapEntry(_possibleScales[0], baseProgression);
  }

  static List<Substitution> test(
      {ChordProgression? base,
      bool inputBase = false,
      required ProgressionBank bank}) {
    assert(base != null || inputBase);
    if (inputBase) {
      base = inputChords();
    }
    var sAP = getAndPrintBase(base!);
    Scale scale = sAP.key;
    ScaleDegreeProgression baseProgression = sAP.value;

    List<Substitution> rated = getRatedSubstitutions(baseProgression, bank);

    print('Suggestions:');
    String subs = '';
    for (Substitution sub in rated) {
      subs += '${sub.toString(baseProgression, scale)}\n\n';
    }
    print(subs);
    return rated;
  }

  static Substitution substituteBy(
      {required ChordProgression base,
      required ProgressionBank bank,
      required int maxIterations}) {
    var sAP = getAndPrintBase(base);
    Scale scale = sAP.key;
    ScaleDegreeProgression baseProgression = sAP.value, prev = baseProgression;
    List<Substitution> rated;
    do {
      rated = getRatedSubstitutions(prev, bank);
      prev = rated.first.substitutedBase;
      maxIterations--;
    } while (maxIterations > 0);
    Substitution result = rated.first;
    print(result.toString(baseProgression, scale));
    return result;
  }
}
