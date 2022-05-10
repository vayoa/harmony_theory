import 'dart:math';

import 'package:thoery_test/extensions/scale_extension.dart';
import 'package:thoery_test/modals/chord_progression.dart';
import 'package:tonic/tonic.dart';

import '../modals/pitch_scale.dart';

class KrumhanslSchmucklerScaleDetection {
  static initialize() {
    if (!_initialized) {
      _initialized = true;
      majorAverage =
          cMajorKeyProfile.fold(0.0, (double prev, double cur) => prev + cur) /
              cMajorKeyProfile.length;
      minorAverage =
          cMinorKeyProfile.fold(0.0, (double prev, double cur) => prev + cur) /
              cMinorKeyProfile.length;
      majorKeyProfiles = [cMajorKeyProfile];
      minorKeyProfiles = [cMinorKeyProfile];
      // Shift the C key profiles to get the rest of them...
      for (int i = 1; i < 12; i++) {
        List<double> majorKeyProfile = [], minorKeyProfile = [];
        for (int j = 0; j < 12; j++) {
          int next = (12 - i + j) % 12;
          majorKeyProfile.add(cMajorKeyProfile[next]);
          minorKeyProfile.add(cMinorKeyProfile[next]);
        }
        majorKeyProfiles.add(majorKeyProfile);
        minorKeyProfiles.add(minorKeyProfile);
      }
    }
  }

  static late final List<List<double>> majorKeyProfiles;
  static late final List<List<double>> minorKeyProfiles;

  static bool _initialized = false;

  static late final double majorAverage;
  static late final double minorAverage;

  static final List<Pitch> tonics = [
    Pitch.parse('C'),
    Pitch.parse('C#'),
    Pitch.parse('D'),
    Pitch.parse('Eb'),
    Pitch.parse('E'),
    Pitch.parse('F'),
    Pitch.parse('F#'),
    Pitch.parse('G'),
    Pitch.parse('Ab'),
    Pitch.parse('A'),
    Pitch.parse('Bb'),
    Pitch.parse('B'),
  ];

  /// We're using the Bellman-Budge chord-based profiles...
  static const List<double> cMajorKeyProfile = [
    16.80,
    0.86,
    12.95,
    1.41,
    13.49,
    11.93,
    1.25,
    20.28,
    1.80,
    8.04,
    0.62,
    10.57,
  ];

  /// We're using the Bellman-Budge chord-based profiles...
  static const List<double> cMinorKeyProfile = [
    18.16,
    0.69,
    12.99,
    13.34,
    1.07,
    11.15,
    1.38,
    21.07,
    7.49,
    1.53,
    0.92,
    10.21,
  ];

  static double correlationValue(List<double> input, List<double> profile,
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

  /// Where indices above 11 are minor scales...
  static List<double> correlations(List<double> input) {
    assert(input.length == 12);
    List<double> correlations = [];
    for (int j = 0; j < 2; j++) {
      List<List<double>> profiles = majorKeyProfiles;
      for (int keyProfile = 0; keyProfile < profiles[j].length; keyProfile++) {
        correlations
            .add(correlationValue(input, profiles[keyProfile], majorAverage));
      }
      profiles = minorKeyProfiles;
    }
    return correlations;
  }

  /// Where indices above 11 are minor scales...
  static PitchScale fromIndex(int index) => PitchScale(
      pattern: index > 11
          ? ScalePatternExtension.minorKey
          : ScalePatternExtension.majorKey,
      tonic: tonics[index % 12]);

  static List<PitchScale> correlate(List<double> input) {
    List<double> correlations =
        KrumhanslSchmucklerScaleDetection.correlations(input);
    List<MapEntry<double, PitchScale>> entries = [
      for (int i = 0; i < correlations.length; i++)
        MapEntry(correlations[i], fromIndex(i))
    ];
    entries.sort(
        (MapEntry<double, PitchScale> a, MapEntry<double, PitchScale> b) =>
            -1 * a.key.compareTo(b.key));
    return [for (MapEntry<double, PitchScale> entry in entries) entry.value];
  }

  static List<PitchScale> correlateChordProgression(
      ChordProgression progression) {
    return correlate(progression.krumhanslSchmucklerInput);
  }
}
