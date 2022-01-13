import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/tonicized_scale_degree_chord.dart';
import 'package:thoery_test/modals/weights/in_scale_weight.dart';
import 'package:thoery_test/modals/weights/weight.dart';

import '../scale_degree_chord.dart';

class HarmonicFunctionWeight extends Weight {
  const HarmonicFunctionWeight()
      : super(
          name: 'HarmonicFunction',
          importance: 5,
          description: WeightDescription.technical,
          scoringStage: ScoringStage.afterSubstitution,
        );

  static const int maxFunctionImportance = 3;

  static final HarmonicFunctionBank _harmonicFunctionBank =
      HarmonicFunctionBank();

  // TODO: Check this with yuval
  // Int values range from 1 - maxFunctionImportance.
  // Boolean is true if we're in minor.
  static Map<int, Map<bool, Map<int, int>>> get sortedFunctions =>
      _harmonicFunctionBank.sortedFunctions;

  // TODO: Write this better...
  ScaleDegreeChord prepareForCheck(
      ScaleDegreeChord chord, ScaleDegreeChord other) {
    if (chord is TonicizedScaleDegreeChord &&
        other is TonicizedScaleDegreeChord) {
      if (chord.tonic.rootDegree == other.tonic.rootDegree) {
        return chord.tonicizedToTonic;
      } else {
        return chord.tonicizedToMajorScale;
      }
    } else if (other is TonicizedScaleDegreeChord &&
        other.tonic.weakEqual(chord)) {
      return ScaleDegreeChord.majorTonicTriad;
    } else if (chord is TonicizedScaleDegreeChord &&
        chord.tonic.weakEqual(other)) {
      return chord.tonicizedToTonic;
    } else {
      return chord;
    }
  }

  @override
  double score(ScaleDegreeProgression progression) {
    int score = 0, count = 0;
    for (int i = 0; i < progression.length - 1; i++) {
      if (progression[i] != null && progression[i + 1] != null) {
        count++;
        int weakHash =
            prepareForCheck(progression[i]!, progression[i + 1]!).weakHash;
        int next =
            prepareForCheck(progression[i + 1]!, progression[i]!).weakHash;
        if (sortedFunctions.containsKey(weakHash)) {
          Map<bool, Map<int, int>> sortedMode = sortedFunctions[weakHash]!;
          Map<int, int> sorted;
          // If no minor functions, choose major functions...
          if (!sortedMode.containsKey(true)) {
            sorted = sortedMode[false]!;
          } else {
            sorted = sortedMode[progression.inMinor]!;
          }
          score += sorted[next] ?? 0;
        }
      }
    }
    return score / (count * maxFunctionImportance);
  }
}

class HarmonicFunctionBank {
  HarmonicFunctionBank() {
    sortedFunctions = {};
    for (MapEntry<String, Map<bool, Map<int, List<String>>>> chord
        in _sortedFunctions.entries) {
      int chordWeakHash = ScaleDegreeChord.parse(chord.key).weakHash;
      if (!sortedFunctions.containsKey(chordWeakHash)) {
        sortedFunctions[chordWeakHash] = {};
      }
      for (MapEntry<bool, Map<int, List<String>>> mode in chord.value.entries) {
        if (!chord.value.containsKey(mode)) {
          sortedFunctions[chordWeakHash]![mode.key] = {};
        }
        for (MapEntry<int, List<String>> scored in mode.value.entries) {
          for (String next in scored.value) {
            sortedFunctions[chordWeakHash]![mode.key]![
                ScaleDegreeChord.parse(next).weakHash] = scored.key;
          }
        }
      }
    }
  }

  late Map<int, Map<bool, Map<int, int>>> sortedFunctions;

  static final Map<String, Map<bool, Map<int, List<String>>>> _sortedFunctions =
      {
    'ii': {
      false: {
        1: ['IV'],
        3: ['V'],
      },
    },
    'IV': {
      false: {
        1: ['I'],
        3: ['V'],
      }
    },
    'V': {
      false: {
        2: ['vi'],
        3: ['I'],
      },
    },
  };
}
