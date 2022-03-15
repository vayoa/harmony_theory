import 'package:thoery_test/modals/chord_progression.dart';
import 'package:tonic/tonic.dart';
import 'package:thoery_test/extensions/scale_extension.dart';

abstract class KrumhanslSchmucklerTest {
  static bool test([int precision = 2]) {
    assert(precision < 24);
    bool _californication = contains(
        californication.krumhanslSchmucklerScales.sublist(0, precision),
        Scale(
            pattern: ScalePatternExtension.minorKey,
            tonic: PitchClass.parse('A')));
    bool _yonatanHakatan = contains(
        yonatanHakatan.krumhanslSchmucklerScales.sublist(0, precision),
        Scale(
            pattern: ScalePatternExtension.majorKey,
            tonic: PitchClass.parse('C')));
    return _californication && _yonatanHakatan;
  }

  static bool contains(List<Scale> scales, Scale value) {
    for (Scale scale in scales) {
      if (scale.equals(value)) return true;
    }
    return false;
  }

  static ChordProgression yonatanHakatan = ChordProgression(
    chords: [
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('Dm'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('C'),
    ],
    durations: [
      1 / 4,
      1 / 4,
      1 / 4,
      1 / 4,
      1 / 4,
      1 / 4,
      1 / 8,
      1 / 8,
      1 / 4,
      1 / 4,
      1 / 4,
      1 / 4,
      1 / 4,
      1 / 4,
      1 / 4,
      1 / 8,
      1 / 8,
      1 / 4,
    ],
  );

  static ChordProgression californication = ChordProgression(
    chords: [
      Chord.parse('Am'),
      Chord.parse('F'),
      Chord.parse('Am'),
      Chord.parse('F'),
      Chord.parse('C'),
      Chord.parse('G'),
      Chord.parse('F'),
      Chord.parse('Dm'),
    ],
    durations: [
      1 / 2,
      1 / 2,
      1 / 2,
      1 / 2,
      1 / 4,
      1 / 4,
      1 / 4,
      1 / 4,
    ],
  );
}
