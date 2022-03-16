import 'package:thoery_test/extensions/pitch_extension.dart';
import 'package:thoery_test/extensions/scale_extension.dart';
import 'package:tonic/tonic.dart';

/// The same as [Scale], but has a [Pitch] as its tonic instead of a
/// [PitchClass]. To allow notes that represent the same pitch (but with a
/// different name) to be distinct scales from each other.
class PitchScale {
  final ScalePattern pattern;
  final Pitch tonic;

  const PitchScale({required this.pattern, required this.tonic});

  PitchScale.common({required Pitch tonic, bool minor = false})
      : this(
            tonic: tonic,
            pattern: minor
                ? ScalePatternExtension.minorKey
                : ScalePatternExtension.majorKey);

  List<Interval> get intervals => pattern.intervals;

  List<Pitch> get pitches =>
      intervals.map((interval) => tonic + interval).toList();

  bool get isMinor => pattern.isMinor;

  String get getCommonName {
    final String scalePattern =
        pattern.name == 'Diatonic Major' ? 'Major' : 'Minor';
    return tonic.commonName + ' ' + scalePattern;
  }

  operator ==(Object other) =>
      other is PitchScale &&
      tonic.octavelessEqual(other.tonic) &&
      pattern.equals(other.pattern);

  @override
  int get hashCode => Object.hash(Object.hashAll(pattern.intervals),
      tonic.accidentalsString, tonic.semitones % 12);
}
