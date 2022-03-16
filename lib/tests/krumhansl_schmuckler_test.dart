import 'package:thoery_test/modals/chord_progression.dart';
import 'package:tonic/tonic.dart';
import 'package:thoery_test/extensions/scale_extension.dart';

import '../modals/pitch_scale.dart';

abstract class KrumhanslSchmucklerTest {
  static bool test([int precision = 2]) {
    assert(precision < 24);
    List<PitchScale> _californicationResults =
        californication.krumhanslSchmucklerScales;
    bool _californication = contains(
        _californicationResults.sublist(0, precision), californicationScale);
    print('Californication - ${californicationScale.getCommonName}:'
        '\n${_californicationResults.map((e) => e.getCommonName).toList()}');
    List<PitchScale> _yonatanHakatanResults =
        yonatanHakatan.krumhanslSchmucklerScales;
    bool _yonatanHakatan = contains(
        _yonatanHakatanResults.sublist(0, precision), yonatanHakatanScale);
    print('Yonatan Hakatan - ${yonatanHakatanScale.getCommonName}:'
        '\n${_yonatanHakatanResults.map((e) => e.getCommonName).toList()}');
    return _californication && _yonatanHakatan;
  }

  static bool contains(List<PitchScale> scales, PitchScale value) {
    for (PitchScale scale in scales) {
      if (scale == value) return true;
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
      1 / 4 * 2,
      1 / 4 * 2,
      1 / 4 * 2,
      1 / 4 * 2,
      1 / 4 * 2,
      1 / 4 * 2,
      1 / 8 * 2,
      1 / 8 * 2,
      1 / 4 * 2,
      1 / 4 * 2,
      1 / 4 * 2,
      1 / 4 * 2,
      1 / 4 * 2,
      1 / 4 * 2,
      1 / 4 * 2,
      1 / 8 * 2,
      1 / 8 * 2,
      1 / 4 * 2,
    ],
  );

  static final yonatanHakatanScale = PitchScale(
      pattern: ScalePatternExtension.majorKey, tonic: Pitch.parse('C'));

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

  static final californicationScale = PitchScale(
      pattern: ScalePatternExtension.minorKey, tonic: Pitch.parse('A'));
}
