import 'package:tonic/tonic.dart';
import 'package:thoery_test/extensions/interval_extension.dart';

extension ScaleExtension on Scale {
  String getCommonName() {
    final String scaleTonic = tonic.toString();
    final String scalePattern =
        pattern.name == 'Diatonic Major' ? 'Major' : 'Minor';
    return scaleTonic + ' ' + scalePattern;
  }

  bool get isMinor => pattern.isMinor;

  bool equals(Scale other) =>
      tonic.integer == other.tonic.integer && pattern.equals(other.pattern);
}

extension ScalePatternExtension on ScalePattern {
  static final ScalePattern majorKey =
      ScalePattern.findByName('Diatonic Major');
  static final ScalePattern minorKey = ScalePattern.findByName('Natural Minor');
  static final List<int> majorKeySemitones = majorKey.intervals
      .map<int>((Interval interval) => interval.semitones)
      .toList();
  static final List<int> minorKeySemitones = minorKey.intervals
      .map<int>((Interval interval) => interval.semitones)
      .toList();

  bool get isMinor => name == 'Natural Minor';

  String get shortName {
    switch (name) {
      case 'Diatonic Major':
        return 'M';
      case 'Natural Minor':
        return 'm';
      default:
        return name;
    }
  }

  bool equals(ScalePattern other) {
    if (intervals.length == other.intervals.length) {
      for (int i = 0; i < intervals.length; i++) {
        if (!intervals[i].equals(other.intervals[i])) return false;
      }
      return true;
    }
    return false;
  }

  int get hashEx => Object.hashAll(intervals);
}
