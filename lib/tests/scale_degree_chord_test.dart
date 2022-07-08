import 'package:tonic/tonic.dart';

import '../extensions/scale_pattern_extension.dart';
import '../modals/pitch_chord.dart';
import '../modals/theory_base/pitch_scale.dart';
import '../modals/theory_base/scale_degree/degree_chord.dart';

// ignore_for_file: avoid_print

abstract class ScaleDegreeChordTest {
  static bool test() {
    print('-- Regular --');
    List<Pitch> pitches = possiblePitches;
    Map<PitchScale, List<DegreeChord>> reverse = {};
    for (Pitch pitch in pitches) {
      PitchScale scale =
          PitchScale(tonic: pitch, pattern: ScalePatternExtension.majorKey);
      for (int i = 0; i < 2; i++) {
        List<String> inScale = [];
        List<DegreeChord> chords = [];
        for (int j = 0; j < pitches.length; j++) {
          Pitch converted = pitches[j];
          String name = '${converted.letterName}${converted.accidentalsString}';
          try {
            chords.add(DegreeChord(scale, PitchChord.parse(name)));
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
    for (MapEntry<PitchScale, List<DegreeChord>> entry in reverse.entries) {
      List<String> chords = entry.value
          .map(
              (DegreeChord sdc) => '$sdc: ${sdc.inScale(entry.key).toString()}')
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
