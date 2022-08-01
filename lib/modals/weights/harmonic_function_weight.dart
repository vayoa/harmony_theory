import 'package:tonic/tonic.dart';

import '../../extensions/interval_extension.dart';
import '../../state/progression_bank.dart';
import '../analysis_tools/pair_map.dart';
import '../progression/degree_progression.dart';
import '../theory_base/degree/degree_chord.dart';
import 'weight.dart';

class HarmonicFunctionWeight extends Weight {
  const HarmonicFunctionWeight()
      : super(
          name: 'HarmonicFunction',
          description: "Prefers progressions that follow common (classical) "
              "harmony rules.",
          importance: 5,
          weightDescription: WeightDescription.technical,
        );

  static const int maxFunctionImportance = 3;

  static PairMap<int> get sortedFunctions => _sortedFunctions;

  static int? getSorted(DegreeChord currentChord, DegreeChord nextChord) =>
      sortedFunctions.getMatch(currentChord, nextChord);

  @override
  Score score({
    required DegreeProgression progression,
    required DegreeProgression base,
    EntryLocation? location,
  }) {
    int score = 0, count = 0;
    String details = '';
    for (int i = 0; i < progression.length; i++) {
      int currPos = i, nextPos = i + 1;
      if (nextPos == progression.length) nextPos = 0;
      if (progression[currPos] != null && progression[nextPos] != null) {
        count++;
        int? pairFunctionValue =
            getSorted(progression[currPos]!, progression[nextPos]!);
        // If the pair exists in the map sortedFunctions map...
        if (pairFunctionValue != null) {
          score += pairFunctionValue;
          details += '${pairFunctionValue > 0 ? 'Adding' : 'Deducting'} '
              '$pairFunctionValue points for ${progression[currPos]!} ->'
              ' ${progression[nextPos]!} (now $score)\n';
        } else {
          // TDC AY: Make sure with yuval that not enforcing the number is ok...
          Interval upFromCurrent = progression[nextPos]!.root.from(
                progression[currPos]!.root,
                enforceNumber: false,
              );
          Interval downFromCurrent = progression[currPos]!.root.from(
                progression[nextPos]!.root,
                enforceNumber: false,
              );
          if (upFromCurrent.equals(Interval.P4)) {
            score += 2;
            details += 'Adding 2 points for  ${progression[currPos]!} ->'
                ' ${progression[nextPos]!} (a 4th up, now $score)\n';
          } else if (downFromCurrent.equals(Interval.P4)) {
            score += 1;
            details += 'Adding 1 point for ${progression[currPos]!} ->'
                ' ${progression[nextPos]!} (a 4th down, now $score)\n';
          } else if (upFromCurrent.equals(Interval.m2) ||
              upFromCurrent.equals(Interval.M2)) {
            score += 1;
            details += 'Adding 1 point for ${progression[currPos]!} ->'
                ' ${progression[nextPos]!} (a 2nd up, now $score)\n';
          } else if (upFromCurrent.equals(Interval.M3) ||
              upFromCurrent.equals(Interval.m3)) {
            score -= 2;
            details += 'Deducting 2 points for ${progression[currPos]!} ->'
                ' ${progression[nextPos]!} (a 3 up, now $score)\n';
          }
        }
      }
    }
    int minPoints = count * -1 * maxFunctionImportance,
        maxPoints = count * maxFunctionImportance;
    return Score(
      score: (score + maxPoints) / (2 * maxPoints),
      details: '${details}Between a minimum of $minPoints points and a '
          'maximum of $maxPoints points this progression got $score.\n',
    );
  }

  static final PairMap<int> _sortedFunctions = PairMap(mapFunctions);

  // Int values range from 1 - maxFunctionImportance.
  static final Map<String, Map<int, List<String>>> mapFunctions = {
    'I': {
      1: ['iii', 'III', 'vi'],
    },
    'I^5': {
      3: ['V'],
    },
    'ii': {
      -1: ['IV'],
      1: ['iii', 'vi', 'viidim'],
      3: ['V'],
    },
    'iidim': {
      1: ['I'],
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
      0: ['I'],
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
      1: ['IV', 'iii', 'V', 'I'],
      2: ['ii'],
    },
    'vi^5': {
      // TODO: Make sure with yuval that this is ok...
      3: ['III'],
    },
    'viidim': {
      -3: ['ii', 'IV', 'iv', 'V'],
      1: ['iii'],
      3: ['I', 'III'],
    },
    /* TODO: Make sure vii7 has the right entries. I just copied them
            from viidim since vii7 doesn't get caught in it
            (only vii7b5 does...) */
    'vii7': {
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
