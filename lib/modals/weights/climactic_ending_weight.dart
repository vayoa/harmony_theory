import 'dart:math';

import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';

class ClimacticEndingWeight extends Weight {
  const ClimacticEndingWeight()
      : super(
          name: 'ClimacticEnding',
          description: "Prefers durations that are closer to the time "
              "signature's step to appear more just before the end in a "
              "descending manner.",
          importance: 2,
          weightDescription: WeightDescription.technical,
        );

  static const int smallerAdd = 1;
  static const int endRange = 2;
  static const int sentenceRange = 1;
  static const int badInRange = -3;
  static const int outRange = -1;
  static const double rangeBeg4Point = 2.0;
  static const double rangeEnd4Point = 3.5;

  /// Adds points if a duration is smaller than the average duration until that
  /// point close to the end (of the song or of a musical sentence {4 measures,
  /// less points...} and deducts points if it's not in that range
  /// (deducts less points than it adds).
  @override
  Score score({
    required ScaleDegreeProgression progression,
    required ScaleDegreeProgression base,
    String? substitutionEntryTitle,
  }) {
    if (progression.duration < 3.0) {
      return Score(
        score: 1.0,
        details: "The progression has less than 3 "
            "measures, which overrides this weight.",
      );
    }

    // The range always starts one measure before the last and ends halfway
    // through the last measure (for instance in a 4 measure song it'll start
    // at the 3rd measure and end at the half-point of the 4th measure).
    int points = 0;
    int count = 0;
    int i = 0;
    String details = "";
    final double step = progression.timeSignature.step;
    final double decimal = progression.timeSignature.decimal;
    final double decimal4 = decimal * 4;
    final double rangeBeg4 = rangeBeg4Point * decimal;
    final double rangeEnd4 = rangeEnd4Point * decimal;
    final double rangeEnd = progression.duration - (decimal / 2);
    final double rangeBeg = progression.duration - (decimal * 2);

    double diff = 0.0;
    double sum = 0.0;
    double last = 0.0;
    while (i < progression.length) {
      count++;
      double dur = progression.durations[i] - diff;
      bool stayAtPos = dur > decimal;
      if (stayAtPos) {
        diff += decimal;
        dur = decimal;
      } else {
        diff = 0.0;
      }

      // if it is in range
      bool inEndRange = sum >= rangeBeg && sum < rangeEnd;
      // if it is in the 4 range...
      bool in4Range = progression.duration % 4 == 0 &&
          (sum % decimal4 >= rangeBeg4 && sum % decimal4 < rangeEnd4);
      if (inEndRange || in4Range) {
        if (dur <= last) {
          bool smaller = dur < last;
          int add = (inEndRange ? endRange : sentenceRange) +
              (smaller ? smallerAdd : 0);
          points += add;
          details += '+$add for ${progression[i]}($dur) '
              '${inEndRange ? 'in range $rangeBeg - $rangeEnd' : 'at the end of a musical sentence'} '
              '($sum away from start) ${smaller ? 'equal to' : 'smaller than'} '
              'the previous duration ($last). Points are now $points.\n';
          // if it is in range but not smaller...
        } else {
          points += badInRange;
          details += '$badInRange for ${progression[i]}($dur) '
              '${inEndRange ? 'in range $rangeBeg - $rangeEnd' : 'at the end of a musical sentence'} '
              '($sum away from start) not smaller or equal to the previous '
              'duration ($last). Points are now $points.\n';
        }
      } // if it is out of range and is equal to step.
      else if (dur == step) {
        points += outRange;
        details += '$outRange for ${progression[i]}($dur) at $sum away from '
            'start equal to step. Points are now '
            '$points.\n';
      }

      sum += dur;
      last = dur;
      if (!stayAtPos) i++;
    }

    int maxPoints = (max(endRange, sentenceRange) + smallerAdd) * count;
    int minPoints = min(outRange, badInRange) * -1 * count;
    details += 'Out of $count durations, between -$minPoints and $maxPoints, '
        'the progression got $points.';
    return Score(
      score: 1.0 - ((points + minPoints) / (maxPoints + minPoints)),
      details: details,
    );
  }
}
