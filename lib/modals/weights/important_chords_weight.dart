import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';

import '../scale_degree.dart';

class ImportantChordsWeight extends Weight {
  const ImportantChordsWeight()
      : super(
          name: 'ImportantChords',
          importance: 3,
          description: WeightDescription.technical,
          scoringStage: ScoringStage.afterSubstitution,
        );

  /// Scores down [progression] if it changed the important tonics in [base],
  /// as well as changing the dominant that goes to them (if present) to
  /// something that's not a dominant.
  //TODO: Maybe change the thing below
  /// NOTE: by saying tonics I mean any chord that has a tonic root and can
  /// be tonicized!
  /// An important tonic is a tonic at the beginning, middle and end of a
  /// progression. If the progression has an odd number of measures, no middle
  /// tonic is considered (middle could be if we have 4 measures at the end
  /// of the 2nd one or at the beginning of the 3rd one. Both are checked).
  // TODO:
  /// להיזהר, בסולם מינור Am
  /// A יכול להיות דומיננטה ל-D
  // להוריד פחות על האמצע
  // אם רוצה תוריד הכי הרבה על האחרון, ואז ראשון ואז אמצע
  // להעלות את החשיבות של המשקולת, שים לב שאפשר להתעלל באמצע
  @override
  Score score({
    required ScaleDegreeProgression progression,
    required ScaleDegreeProgression base,
  }) {
    int points = 0, max = 0;
    String details = '';
    if (_isTonic(base[0])) {
      max++;
      if (!_isTonic(progression[0])) {
        points++;
        details +=
            '-1 for tonic in the beginning of base (${base[0]}) replaced by a '
            '${progression[0]} in the beginning of the sub progression. '
            'Points: $points.\n';
      }
    }
    // i
    if (_isTonic(base.values.last)) {
      max++;
      if (!_isTonic(progression.values.last)) {
        points++;
        details +=
            '-1 for tonic in the end of base (${base.values.last}) replaced by a '
            '${progression.values.last} in the end of the sub progression. '
            'Points: $points.\n';
      } else if (base.deriveHarmonicFunctionOf(base.length - 2) ==
          HarmonicFunction.dominant) {
        max++;
        if (progression.deriveHarmonicFunctionOf(progression.length - 2) !=
            HarmonicFunction.dominant) {
          points++;
          details += '-1 for dominant going to tonic in the end of base '
              '(${base[base.length - 2]} -> ${base.values.last}) replaced by '
              'a ${progression[progression.length - 2]} going to a tonic in '
              'the end of the sub progression. Points: $points.\n';
        }
      }
    }

    // Progression and base will have the same duration and time signature,
    // so their measure count will be the same...
    // See documentation as to why this is done twice.
    if (base.measureCount % 2 == 0) {
      bool stop = false;
      int middleBase = base.getIndexFromDuration(base.duration / 2);
      for (int i = 0; i < 2; i++) {
        bool stopNext = false;
        middleBase += i;
        if (base.length < middleBase && _isTonic(base[middleBase])) {
          max++;
          int middleSub =
              progression.getIndexFromDuration(progression.duration / 2) + i;
          // If we're a tonic and by chance the next chord will also be a tonic,
          // there's no need to check if a dominant is preceding it, since we
          // know there isn't...
          stopNext = true;
          if (!_isTonic(progression[middleSub])) {
            points++;
            details +=
                '-1 for tonic in the middle of base (${base[middleBase]}) '
                'replaced by a ${progression[middleSub]} in the end of the sub '
                'progression. Points: $points.\n';
          } else if (!stop &&
              base.deriveHarmonicFunctionOf(middleBase - 1) ==
                  HarmonicFunction.dominant) {
            max++;
            if (progression.deriveHarmonicFunctionOf(middleSub - 1) !=
                HarmonicFunction.dominant) {
              points++;
              details += '-1 for dominant going to tonic in the middle of base '
                  '(${base[middleBase - 1]} -> ${base[middleBase]}) replaced by '
                  'a ${progression[middleSub - 1]} going to a tonic in '
                  'the end of the sub progression. Points: $points.\n';
            }
          }
        }
        if (stopNext) stop = true;
      }
    }
    double finalScore = 1.0;
    if (max != 0) {
      finalScore -= (points / max);
    }
    return Score(score: finalScore, details: details);
  }

  //TODO: Maybe change this and the explanation above.
  bool _isTonic(ScaleDegreeChord? chord) =>
      chord != null &&
      (chord.rootDegree == ScaleDegree.tonic ||
          chord.rootDegree == ScaleDegree.vi) &&
      chord.canBeTonic;
}
