import 'dart:io';

import 'package:thoery_test/extensions/scale_extension.dart';
import 'package:thoery_test/main.dart';
import 'package:thoery_test/modals/chord_progression.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
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

  static List<ScaleDegreeProgression> getPossibleSubstitutions(
      ScaleDegreeProgression base, ProgressionBank bank) {
    final List<ScaleDegreeProgression> substitutions = [];
    for (ScaleDegreeChord? chord in base.values) {
      if (chord != null) {
        // TODO: Implement tonicization optimization.
        List<ScaleDegreeProgression>? progressions =
            bank.getByGroup(chord, false);
        if (progressions != null && progressions.isNotEmpty) {
          for (ScaleDegreeProgression sub in progressions) {
            substitutions.addAll(base.getPossibleSubstitutions(sub));
          }
        }
      }
    }
    // TODO: Optimize...
    return substitutions.toSet().toList();
  }

  // TODO: Implement preferences and weight parameters (before sub, after...).
  static double scoreProgression(ScaleDegreeProgression progression) =>
      weights.fold<double>(
          0.0,
          (double previousValue, Weight weight) =>
              previousValue + weight.score(progression));

  static List<RatedSubstitution> getRatedSubstitutions(
      ScaleDegreeProgression base, ProgressionBank bank) {
    List<ScaleDegreeProgression> substitutions =
        getPossibleSubstitutions(base, bank);
    List<RatedSubstitution> rated = [
      for (ScaleDegreeProgression sub in substitutions)
        RatedSubstitution(sub, scoreProgression(sub))
    ];
    rated.sort((RatedSubstitution a, RatedSubstitution b) =>
        -1 * a.rating.compareTo(b.rating));
    return rated;
  }

  static List<RatedSubstitution> test(
      {ChordProgression? base,
      bool inputBase = false,
      required ProgressionBank bank}) {
    assert(base != null || inputBase);
    if (inputBase) {
      base = inputChords();
    }
    print('Your Progression:\n$base.');

    // Detect the base progressions' scale
    final List<Scale> _possibleScales = base!.matchWithScales();
    print('Scale Found: ${_possibleScales[0].getCommonName()}.');

    // Convert the base progression to roman numerals, we used the most probable
    // scale that was detected (which would be the first in the list).
    final ScaleDegreeProgression baseProgression =
        ScaleDegreeProgression.fromChords(_possibleScales[0], base);
    print('In Roman Numerals: $baseProgression.\n');

    List<RatedSubstitution> rated =
        getRatedSubstitutions(baseProgression, bank);

    print('Suggestions:');
    String subs = '';
    for (RatedSubstitution rS in rated) {
      subs +=
          '${rS.substitution} -> ${rS.substitution.inScale(_possibleScales[0])}:'
          ' ${rS.rating.toStringAsFixed(3)},\n';
    }
    print(subs);
    return rated;
  }
}
