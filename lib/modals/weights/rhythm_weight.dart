import 'dart:math';

import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';

class RhythmWeight extends Weight {
  const RhythmWeight()
      : super(
          name: 'Rhythm',
          scoringStage: ScoringStage.afterSubstitution,
          // TODO: Not sure about this description...
          description: WeightDescription.diatonic,
          importance: 4,
        );

  // TODO: Not sure about taking down points for not whole divisions...
  /// The weight will score progressions lower if they have durations that are
  /// smaller than the most common duration there divided by 2 as well as for
  /// any durations that don't divide wholly by
  /// (1 / [progression.timeSignature.denominator]) / 2.
  @override
  Score score(ScaleDegreeProgression progression) {
    Map<double, int> commonDur = {};
    double step = (1 / progression.timeSignature.denominator) / 2;
    int count = 0;
    for (double duration in progression.durations) {
      // TODO: This logic might need fixing...
      if (commonDur.containsKey(duration)) {
        commonDur[duration] = commonDur[duration]! + 1;
      } else {
        commonDur[duration] = 1;
      }
    }
    double common = commonDur.entries.reduce((value, element) {
      if (value.value > element.value) return value;
      return element;
    }).key;
    String details = 'Step: $step, Common: $common.\n';
    for (double duration in progression.durations) {
      if (duration < common / 2) {
        count++;
        details += 'Took down points for $duration smaller than $common,\n';
      } else if (duration % step != 0 && step % duration != 0) {
        count++;
        details +=
            'Took down points for $duration not dividing wholly by $step,\n';
      }
    }
    return Score(score: 1.0 - (count / progression.length), details: details);
  }
}
