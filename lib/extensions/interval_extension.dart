import 'package:tonic/tonic.dart';

extension IntervalExtension on Interval {
  bool equals(Object other) =>
      other is Interval &&
      (number == other.number && qualitySemitones == other.qualitySemitones);

  int get getHash => Object.hash(number, qualitySemitones);
}
