import 'package:thoery_test/extensions/interval_extension.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/tonicized_scale_degree_chord.dart';
import 'package:thoery_test/modals/weights/weight.dart';
import 'package:tonic/tonic.dart';

import '../scale_degree_chord.dart';

class HarmonicFunctionWeight extends Weight {
  const HarmonicFunctionWeight()
      : super(
          name: 'HarmonicFunction',
          importance: 5,
          description: WeightDescription.technical,
          scoringStage: ScoringStage.afterSubstitution,
        );

  static final HarmonicFunctionBank _harmonicFunctionBank =
      HarmonicFunctionBank();

  // TODO: Check this with yuval
  // Int values range from 1 - maxFunctionImportance.
  // Boolean is true if we're in minor.
  static Map<int, Map<int, int>> get sortedFunctions =>
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
  Score score({
    required ScaleDegreeProgression progression,
    required ScaleDegreeProgression base,
  }) {
    int maxImportance = HarmonicFunctionBank.maxFunctionImportance;
    int score = 0, count = 0;
    String details = '';
    for (int i = 0; i < progression.length - 1; i++) {
      if (progression[i] != null && progression[i + 1] != null) {
        count++;
        int weakHash =
            prepareForCheck(progression[i]!, progression[i + 1]!).weakHash;
        int next =
            prepareForCheck(progression[i + 1]!, progression[i]!).weakHash;
        if (sortedFunctions.containsKey(weakHash) &&
            sortedFunctions[weakHash]![next] != null) {
          Map<int, int> sorted = sortedFunctions[weakHash]!;
          score += sorted[next]!;
          String verb = sorted[next]! > 0 ? 'Adding' : 'Deducting';
          details += verb +
              ' ${sorted[next]} points for'
                  ' ${progression[i]!} -> ${progression[i + 1]!} (now $score)\n';
        } else {
          Interval upFromCurrent =
              progression[i + 1]!.rootDegree.from(progression[i]!.rootDegree);
          Interval downFromCurrent =
              progression[i]!.rootDegree.from(progression[i + 1]!.rootDegree);
          if (upFromCurrent.equals(Interval.P4)) {
            score += 2;
            details += 'Adding 2 points for'
                ' ${progression[i]!} -> ${progression[i + 1]!} (a 4th up, now $score)\n';
          } else if (downFromCurrent.equals(Interval.P4)) {
            score += 1;
            details += 'Adding 1 point for'
                ' ${progression[i]!} -> ${progression[i + 1]!} (a 4th down, now $score)\n';
          } else if (upFromCurrent.equals(Interval.m2) ||
              upFromCurrent.equals(Interval.M2)) {
            score += 1;
            details += 'Adding 1 point for'
                ' ${progression[i]!} -> ${progression[i + 1]!} (a 2nd up, now $score)\n';
          } else if (upFromCurrent.equals(Interval.M3) ||
              upFromCurrent.equals(Interval.m3)) {
            score -= 2;
            details += 'Deducting 2 points for '
                '${progression[i]!} -> ${progression[i + 1]!} '
                '(a 3 up, now $score)\n';
          }
        }
      }
    }
    int minPoints = count * -1 * maxImportance,
        maxPoints = count * maxImportance;
    return Score(
      score: (score + maxPoints) / (2 * maxPoints),
      details: details +
          'Between a minimum of $minPoints points and a maximum of $maxPoints '
              'points this progression got $score.\n',
    );
  }
}

class HarmonicFunctionBank {
  static const int maxFunctionImportance = 3;

  HarmonicFunctionBank() {
    sortedFunctions = {};
    for (MapEntry<String, Map<int, List<String>>> chord
        in _sortedFunctions.entries) {
      int chordWeakHash = ScaleDegreeChord.parse(chord.key).weakHash;
      if (!sortedFunctions.containsKey(chordWeakHash)) {
        sortedFunctions[chordWeakHash] = {};
      }
      for (MapEntry<int, List<String>> scored in chord.value.entries) {
        assert(scored.key <= maxFunctionImportance &&
            scored.key >= -1 * maxFunctionImportance);
        for (String next in scored.value) {
          sortedFunctions[chordWeakHash]![
              ScaleDegreeChord.parse(next).weakHash] = scored.key;
        }
      }
    }
  }

  late Map<int, Map<int, int>> sortedFunctions;

  static final Map<String, Map<int, List<String>>> _sortedFunctions = {
    'I': {
      1: ['iii', 'III', 'vi'],
    },
    'ii': {
      -1: ['IV'],
      1: ['iii', 'vi', 'viidim'],
      3: ['V'],
    },
    'iidim': {
      3: ['V'],
    },
    'iii': {
      -3: ['I', 'viidim'],
      -1: ['V'],
      1: ['ii'],
      2: ['IV'],
    },
    'III': {
      2: ['IV'],
      3: ['vi'],
    },
    'iv': {
      1: ['I'],
      2: ['V'],
    },
    'IV': {
      -2: ['vi'],
      1: ['I'],
      2: ['ii', 'V', 'viidim'],
    },
    'V': {
      -2: ['viidim'],
      -1: ['ii', 'iii'],
      1: ['bVI'],
      2: ['vi'],
      3: ['I'],
    },
    'vi': {
      // TODO: Not sure about the score here, should be lower then a ii -> V.
      1: ['IV', 'iii', 'V', 'I'],
      2: ['ii'],
    },
    'viidim': {
      -3: ['ii', 'IV', 'iv', 'V'],
      1: ['iii'],
      3: ['I', 'III'],
    },
    'bVI': {
      1: ['bVII', 'V'],
    },
    'bVII': {
      2: ['I'],
    },
  };
}
