import 'dart:math';

import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';

class NewRhythmWeight extends Weight {
  const NewRhythmWeight()
      : super(
          name: 'NewRhythm',
          importance: 4,
          scoringStage: ScoringStage.afterSubstitution,
          // TODO: Not sure about this description...
          description: WeightDescription.diatonic,
        );

  /* TODO: Instead, just don't allow durations lower than the step and ones
          that aren't multiples of 2 and step...
   */

  /// Completely Scores down progressions with durations less the the
  /// progression's step ([progression.timeSignature.step]), as well as
  /// durations that aren't multiples of 2^n and step (where n is an integer...).
  /// Scores up progressions that have faster durations a bit before the end
  /// (for instance in a 4/4 where 1/4 comes
  @override
  Score score(
      {required ScaleDegreeProgression progression,
      required ScaleDegreeProgression base}) {
    double step = progression.timeSignature.step;
    if (progression.minDuration < step) {
      return Score(
        score: 0.0,
        details: "Progression has a ${progression.minDuration} in "
            "it, which is smaller than it's step ($step).",
      );
    }

    // In a 4 measures song, we'd like the wild rhythms to happen more towards
    // the 3rd measure, which means the range of durations from the start is
    // 2 - 3.
    // In an 8 measures song, we'd like the wild rhythms to happen more towards
    // the 6th - 7th measures. Which means the range is now 5 - 7.
    // So the range ends one measure before the last and is of
    // length -> (measureNum / 4).round().
    double sum = 0.0;
    int points = 0, rangeCount = 0;
    double rangeEnd = 0, rangeBeg = 0;
    String details = "";
    if (progression.measureCount >= 4) {
      rangeEnd = progression.duration - progression.timeSignature.decimal;
      rangeBeg = rangeEnd -
          ((progression.measureCount / 4).round() *
              progression.timeSignature.decimal);
    }
    for (int i = 0; i < progression.length; i++) {
      double dur = progression.durations[i], mult = dur / step;
      // TODO: Optimize...
      //  Log2...
      double l = log(mult) / ln2;
      if (l.truncate() != l) {
        return Score(
          score: 0.0,
          details: "Progression has a $dur in it, which isn't a multiple of 2 "
              "and it's step ($step).",
        );
      }
      if (sum >= rangeBeg && sum < rangeEnd) {
        rangeCount++;
        /* TODO: Currently if dur is smaller than the average dur so far,
                  should be more sophisticated. */
        double avg = sum / (i + 1);
        if (dur < avg) {
          points++;
          details += 'Adding points for $dur in range $rangeBeg - $rangeEnd '
              'smaller than the current avg ($avg). Points are now $points.\n';
        }
      }
      sum += dur;
    }
    details += 'Out of $rangeCount durations in range $rangeBeg - $rangeEnd, '
        '$points durations were smaller than the average duration so far.';
    return Score(
        score: rangeCount == 0 ? 0 : points / rangeCount, details: details);
  }
}
