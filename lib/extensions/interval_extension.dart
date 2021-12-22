import 'package:tonic/tonic.dart';

extension IntervalExtension on Interval {
  bool equals(Object other) =>
      other is Interval &&
      (number == other.number && qualitySemitones == other.qualitySemitones);

  int get hashEx => Object.hash(number, qualitySemitones);
}
