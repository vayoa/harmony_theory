import 'package:tonic/tonic.dart';


/// The same as [Scale], but has a [Pitch] as its tonic instead of a
/// [PitchClass]. To allow notes that represent the same pitch (but with a
/// different name) to be distinct scales from each other.
class PitchScale {
  final ScalePattern pattern;
  final Pitch tonic;

  PitchScale({required this.pattern, required this.tonic});

  List<Interval> get intervals => pattern.intervals;

  List<Pitch> get pitches =>
      intervals.map((interval) => tonic + interval).toList();

}
