import 'dart:math';

import 'package:thoery_test/extensions/scale_extension.dart';
import 'package:thoery_test/modals/chord_progression.dart';
import 'package:tonic/tonic.dart';

class KrumhanslSchmucklerScaleDetection {
  KrumhanslSchmucklerScaleDetection() {
    majorAverage =
        CMajorKeyProfile.fold(0.0, (double prev, double cur) => prev + cur) /
            CMajorKeyProfile.length;
    minorAverage =
        CMinorKeyProfile.fold(0.0, (double prev, double cur) => prev + cur) /
            CMinorKeyProfile.length;
    majorKeyProfiles = [CMajorKeyProfile];
    minorKeyProfiles = [CMinorKeyProfile];
    // Shift the C key profiles to get the rest of them...
    for (int i = 1; i < 12; i++) {
      List<double> majorKeyProfile = [], minorKeyProfile = [];
      for (int j = 0; j < 12; j++) {
        int next = (12 - i + j) % 12;
        majorKeyProfile.add(CMajorKeyProfile[next]);
        minorKeyProfile.add(CMinorKeyProfile[next]);
      }
      majorKeyProfiles.add(majorKeyProfile);
      minorKeyProfiles.add(minorKeyProfile);
    }
  }

  late final List<List<double>> majorKeyProfiles;
  late final List<List<double>> minorKeyProfiles;

  late final double majorAverage;
  late final double minorAverage;

  static const List<double> CMajorKeyProfile = [
    6.35,
    2.23,
    3.48,
    2.33,
    4.38,
    4.09,
    2.52,
    5.19,
    2.39,
    3.66,
    2.29,
    2.88,
  ];

  static const List<double> CMinorKeyProfile = [
    6.33,
    2.68,
    3.52,
    5.38,
    2.60,
    3.53,
    2.54,
    4.75,
    3.98,
    2.69,
    3.34,
    3.17,
  ];

  double correlationValue(List<double> input, List<double> profile,
      [double? profileAvg]) {
    double inputAvg =
        input.reduce((value, element) => value + element) / input.length;
    profileAvg ??=
        profile.reduce((value, element) => value + element) / profile.length;
    double numerator = 0.0;
    double sum1 = 0.0, sum2 = 0.0;
    for (int i = 0; i < 12; i++) {
      numerator += (input[i] - inputAvg) * (profile[i] - profileAvg);
      sum1 += pow(input[i] - inputAvg, 2);
      sum2 += pow(profile[i] - profileAvg, 2);
    }
    double denominator = sqrt(sum1 * sum2);
    return numerator / denominator;
  }

  // Where indices above 11 are minor scales...
  int maxCorrelationIndex(List<double> input) {
    assert(input.length == 12);
    double inputAvg =
        input.reduce((value, element) => value + element) / input.length;
    double maxCorrelation = double.negativeInfinity;
    int maxIndex = 0;
    for (int j = 0; j < 2; j++) {
      List<List<double>> profiles = majorKeyProfiles;
      double avg = majorAverage;
      for (int keyProfile = 0; keyProfile < profiles[j].length; keyProfile++) {
        double corr =
            correlationValue(input, profiles[keyProfile], majorAverage);
        if (corr > maxCorrelation) {
          maxCorrelation = corr;
          maxIndex = keyProfile;
          if (j == 1) maxIndex += 12;
        }
      }
      profiles = minorKeyProfiles;
      avg = minorAverage;
    }
    return maxIndex;
  }

  Scale correlate(List<double> input) {
    int index = maxCorrelationIndex(input);
    return Scale(
        pattern: index > 11
            ? ScalePatternExtension.minorKey
            : ScalePatternExtension.majorKey,
        tonic: PitchClass.fromSemitones(index % 12));
  }

  Scale chordProgressionCorrelation(ChordProgression progression) {
    return correlate(progression.krumhanslSchmucklerInput);
  }
}
