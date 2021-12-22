import 'package:tonic/tonic.dart';
import 'package:thoery_test/extensions/interval_extension.dart';

extension ScaleExtension on Scale {
  String getCommonName() {
    final String scaleTonic = tonic.toString();
    final String scalePattern =
    pattern.name == 'Diatonic Major' ? 'Major' : 'Minor';
    return scaleTonic + ' ' + scalePattern;
  }
}

extension ScalePatternExtension on ScalePattern {
  bool equals(Object other) {
    if (other is ScalePattern && intervals.length == other.intervals.length) {
      for (int i = 0; i < intervals.length; i++) {
        if (!intervals[i].equals(other.intervals[i])) return false;
      }
      return true;
    }
    return false;
  }

  int get hashEx => Object.hashAll(intervals);
}
