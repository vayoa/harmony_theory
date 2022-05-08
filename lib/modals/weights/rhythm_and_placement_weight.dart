import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';

class RhythmAndPlacementWeight extends Weight {
  const RhythmAndPlacementWeight()
      : super(
          name: 'RhythmAndPlacement',
          description: "Scores down values that get cut by a measure or it's "
              "half-point. When they're not at the end of a musical sentence "
              "or fill up multiple measures.",
          importance: 4,
          weightDescription: WeightDescription.technical,
        );

  static const int measureCuts = 1;
  static const int unevenMeasureCuts = 1;
  static const int halfPointCuts = 1;
  static const int maxPoints = measureCuts + unevenMeasureCuts + halfPointCuts;

  /// Scores down anytime a chord gets cut by a measure (| I V | V I | for
  /// instance) - [evenMeasureCuts].
  ///
  /// (This does not count chords that have a duration that is a multiple of a
  /// measure and start at the beginning of a measure [| V | V | for instance],
  /// and for instances where a musical "sentence" ends [the end of 4 measures]).
  ///
  /// Subtracts more points if the cut parts aren't even (| I | I V | for
  /// instance) - [unevenMeasureCuts].
  ///
  /// Also scores down when (if in an even time signature) when a chord gets
  /// cut by the half point of a measure and doesn't start from it's beginning
  /// (| I V V I | for instance) - [halfPointCuts].
  ///
  /// All of these are additive.
  @override
  Score score({
    required ScaleDegreeProgression progression,
    required ScaleDegreeProgression base,
    String? substitutionEntryTitle,
  }) {
    String details = '';
    int points = 0;
    double decimal = progression.timeSignature.decimal;
    double halfPoint = decimal / 2;
    bool even = progression.timeSignature.numerator % 2 == 0;
    double sentence = 4 * decimal;
    for (int i = 0; i < progression.length; i++) {
      double duration = progression.durations[i];
      double durationTo = progression.durations.real(i) - duration;
      double absoluteDurationTo = durationTo % decimal;
      // If a chord gets cut by a measure.
      double sum = absoluteDurationTo + duration;
      if (!(absoluteDurationTo == 0 && duration % decimal == 0) &&
          sum > decimal &&
          // Last check is that it's not the end of a musical sentence.
          (durationTo + duration).floor() % sentence != 0) {
        points += measureCuts;
        details += 'Deducting $measureCuts points for '
            '${progression.values[i]}($duration) at $durationTo being cut by a '
            'measure. Points: $points.\n';
        double cut2 = sum - decimal, cut1 = duration - cut2;
        if (cut1 != cut2) {
          points += unevenMeasureCuts;
          details += 'Deducting $unevenMeasureCuts points for '
              '${progression.values[i]}($duration) at $durationTo being cut by '
              'a measure unevenly. Points: $points.\n';
        }
      }
      if (even &&
          absoluteDurationTo != 0 &&
          absoluteDurationTo < halfPoint &&
          sum > halfPoint) {
        points += halfPointCuts;
        details += 'Deducting $halfPointCuts points for '
            '${progression.values[i]}($duration) at $durationTo being cut by '
            'the half point of a measure. Points: $points.\n';
      }
    }
    return Score(
        score: 1.0 - (points / (progression.length * maxPoints)),
        details: details);
  }
}
