import 'package:thoery_test/modals/scale_degree.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:tonic/tonic.dart';

class TonicizedScaleDegreeChord extends ScaleDegreeChord {
  final ScaleDegreeChord tonic;
  final ScaleDegreeChord tonicizedToTonic;
  final ScaleDegreeChord tonicizedToMajorScale;

  TonicizedScaleDegreeChord.raw(
      {required this.tonic,
      required this.tonicizedToTonic,
      required this.tonicizedToMajorScale})
      : super.raw(
            tonicizedToMajorScale.pattern, tonicizedToMajorScale.rootDegree);

  TonicizedScaleDegreeChord(
      {required ScaleDegreeChord tonic,
      required ScaleDegreeChord tonicizedToTonic,
      ScaleDegreeChord? tonicizedToMajorScale})
      : this.raw(
            tonic: tonic is TonicizedScaleDegreeChord
                ? (tonic.tonicizedToMajorScale)
                : tonic,
            tonicizedToTonic: tonicizedToTonic,
            tonicizedToMajorScale:
                tonicizedToMajorScale ?? tonicizedToTonic.tonicizedFor(tonic));

  TonicizedScaleDegreeChord.shifted(
      {required ScaleDegreeChord tonic,
      required ScaleDegreeChord tonicizedToMajorScale})
      : this.raw(
            tonic: tonic is TonicizedScaleDegreeChord
                ? (tonic.tonicizedToMajorScale)
                : tonic,
            tonicizedToTonic: tonicizedToMajorScale.shiftFor(tonic),
            tonicizedToMajorScale: tonicizedToMajorScale);

  @override
  String toString() => '$tonicizedToTonic/$tonic';
}
