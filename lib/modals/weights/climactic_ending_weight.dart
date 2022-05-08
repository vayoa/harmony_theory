import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';

class ClimacticEndingWeight extends Weight {
  const ClimacticEndingWeight()
      : super(
          name: 'ClimacticEnding',
          description:
              "Prefers durations that are closer to the time signature's step "
              "to appear more just before the end.",
          importance: 2,
          weightDescription: WeightDescription.technical,
        );

  @override
  Score score(
      {required ScaleDegreeProgression progression,
      required ScaleDegreeProgression base}) {
    // In a 4 measures song, we'd like the wild rhythms to happen more towards
    // the 3rd measure, which means the range of durations from the start is
    // 2 - 3.
    // In an 8 measures song, we'd like the wild rhythms to happen more towards
    // the 6th - 7th measures. Which means the range is now 5 - 7.
    double sum = 0.0;
    int points = 0, rangeCount = 0;
    double rangeEnd = 0, rangeBeg = 0;
    String details = "";
    final double decimal = progression.timeSignature.decimal;
    final double decimal4 = decimal * 4;
    final double rangeBeg4 = 2 * decimal, rangeEnd4 = 3 * decimal;
    if (progression.measureCount == 4) {
      rangeBeg = rangeBeg4;
      rangeEnd = rangeEnd4;
    } else {
      rangeEnd = progression.duration - decimal;
      rangeBeg = rangeEnd - ((progression.measureCount / 4).round() * decimal);
      if (progression.measureCount % 2 != 0 || progression.measureCount <= 2) {
        rangeBeg += (decimal / 2);
        rangeEnd += (decimal / 2);
      }
    }
    for (int i = 0; i < progression.length; i++) {
      double dur = progression.durations[i];
      double avg = sum / (i + 1);
      if (sum >= rangeBeg && sum < rangeEnd ||
          (sum % decimal4 >= rangeBeg4 && sum % decimal4 < rangeEnd4)) {
        rangeCount++;
        if (dur < avg) {
          points++;
          details +=
              '+1 for ${progression[i]}($dur) in range $rangeBeg - $rangeEnd '
              '(or at the end of a musical sentence) smaller than the current '
              'avg ($avg). Points are now $points.\n';
        }
      }
      sum += dur;
    }
    details +=
        'Out of $rangeCount durations in range $rangeBeg - $rangeEnd (or at '
        'the end of a musical sentence), $points durations were smaller than '
        'the average duration so far.';
    return Score(
        score: rangeCount == 0 ? 0.0 : points / rangeCount, details: details);
  }
}
