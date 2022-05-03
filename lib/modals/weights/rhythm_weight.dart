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

  static const int maxPointsToScoreDown = 2;

  /// The weight will score progressions lower if they have durations that are
  /// smaller than the most common duration there divided by 2 as well as for
  /// any durations that don't divide wholly by the progressions step
  /// (1 / [progression.timeSignature.denominator]) and step / 2.
  /*
  TODO: Not sure about taking down points for not whole divisions...
  TODO: Maybe take down points for durations that are multiples of 4 (like an
   1/8 to a 1/2).
  */
  // TDC: Convert to absolute durations!
  @override
  Score score({
    required ScaleDegreeProgression progression,
    required ScaleDegreeProgression base,
  }) {
    Map<double, int> commonDur = {};
    double step = 1 / progression.timeSignature.denominator;
    int count = 0;
    for (int i = 0; i < progression.durations.length; i++) {
      double duration = progression.durations[i];
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
    for (int i = 0; i < progression.durations.length; i++) {
      double duration = progression.durations[i];
      if (duration < common / 2) {
        count += 2;
        details +=
            'Took down 2 points for $duration smaller than $common / 2,\n';
      } else if (duration % (step / 2) != 0 && (step / 2) % duration != 0) {
        count += 2;
        details +=
            'Took down 2 points for $duration not dividing wholly by $step / 2'
            ' (${step / 2}),\n';
      } else if (duration % step != 0 && step % duration != 0) {
        count++;
        details +=
            'Took down 1 point for $duration not dividing wholly by $step,\n';
      }
    }
    return Score(
      score: 1.0 - (count / (progression.length * maxPointsToScoreDown)),
      details: details,
    );
  }
}
