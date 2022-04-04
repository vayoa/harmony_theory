import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/extensions/scale_extension.dart';
import 'package:tonic/tonic.dart';

import '../modals/pitch_scale.dart';
import '../modals/scale_degree_chord.dart';

abstract class ScaleDegreeChordTest {
  static bool test() {
    print('-- Regular --');
    List<Pitch> _possiblePitches = possiblePitches;
    Map<PitchScale, List<ScaleDegreeChord>> reverse = {};
    for (Pitch pitch in _possiblePitches) {
      PitchScale scale =
          PitchScale(tonic: pitch, pattern: ScalePatternExtension.majorKey);
      for (int i = 0; i < 2; i++) {
        List<String> inScale = [];
        List<ScaleDegreeChord> chords = [];
        for (int j = 0; j < _possiblePitches.length; j++) {
          Pitch converted = _possiblePitches[j];
          String name = '${converted.letterName}${converted.accidentalsString}';
          try {
            chords.add(ScaleDegreeChord(scale, Chord.parse(name)));
            inScale.add('$name: ${chords.last}');
          } catch (e) {
            print('$converted in $scale failed:');
            Pitch cRoot = converted, tRoot = scale.tonic.toPitch();
            int semitones = (cRoot.semitones - tRoot.semitones) % 12;
            int number = 1 + cRoot.letterIndex - tRoot.letterIndex;
            if (number <= 0) number += 7;
            print('semitones: $semitones, number: $number.');
            rethrow;
          }
        }
        print(
            '${pitch.letterName}${pitch.accidentalsString}${i == 0 ? '' : 'm'}'
            ': $inScale');
        reverse[scale] = chords;
        scale =
            PitchScale(tonic: pitch, pattern: ScalePatternExtension.minorKey);
      }
    }
    print('\n-- Reversed --');
    for (MapEntry<PitchScale, List<ScaleDegreeChord>> entry
        in reverse.entries) {
      List<String> chords = entry.value
          .map((ScaleDegreeChord sdc) =>
              '$sdc: ${sdc.inScale(entry.key).commonName}')
          .toList();
      print('${entry.key}: $chords');
    }
    return true;
  }

  static List<Pitch> get possiblePitches {
    List<Pitch> possiblePitches = [];
    String start = 'A';
    int last = 'G'.codeUnitAt(0);
    List<String> adds = ['', 'b', '#'];
    while (start.codeUnitAt(0) <= last) {
      for (String add in adds) {
        possiblePitches.add(Pitch.parse('$start$add'));
      }
      start = String.fromCharCode(start.codeUnitAt(0) + 1);
    }
    return possiblePitches;
  }
}
