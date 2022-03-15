import 'dart:math';

import 'package:thoery_test/extensions/scale_extension.dart';
import 'package:tonic/tonic.dart';

import '../modals/scale_degree_chord.dart';

abstract class ScaleDegreeChordTest {
  static bool test() {
    List<Pitch> _possiblePitches = possiblePitches;
    for (Pitch pitch in _possiblePitches) {
      Scale scale = Scale(
          tonic: pitch.toPitchClass(), pattern: ScalePatternExtension.majorKey);
      for (int i = 0; i < 2; i++) {
        List<String> inScale = [];
        for (int j = 0; j < _possiblePitches.length; j++) {
          Pitch converted = _possiblePitches[j];
          String name = '${converted.letterName}${converted.accidentalsString}';
          try {
            inScale.add('$name: ${ScaleDegreeChord(scale, Chord.parse(name))}');
          } catch (e) {
            print('$converted in ${scale.getCommonName()} failed:');
            Pitch cRoot = converted, tRoot = scale.tonic.toPitch();
            int semitones = (cRoot.semitones - tRoot.semitones) % 12;
            int number = 1 + cRoot.letterIndex - tRoot.letterIndex;
            if (number <= 0) number += 7;
            print('semitones: $semitones, number: $number.');
            rethrow;
          }
        }
        print(
            '${pitch.letterName}${pitch.accidentalsString}${i == 0 ? '' : 'm'}: $inScale');
        scale = Scale(
            tonic: pitch.toPitchClass(),
            pattern: ScalePatternExtension.minorKey);
      }
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
