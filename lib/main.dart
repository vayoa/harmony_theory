import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:tonic/tonic.dart';
import 'package:thoery_test/extensions/chord_extension.dart';

import 'modals/chord_list.dart';

void main() {
  // Example use-case:
  // Base chord progression based on which we suggests chords.
  final ChordList _baseChordProgression = ChordList([
    Chord.parse('F'),
    Chord.parse('G'),
    Chord.parse('C'),
  ]);

  // The user's saved chord progressions. These are already converted to
  // ScaleDegreeChord.
  const List<List<String>> _drySavedProgressions = [
    ['ii', 'V', 'I'],
    ['IV', 'V', 'I'],
    ['V', 'I'],
    ['IV', 'iv', 'I'],
    ['IV', 'I'],
    ['iv', 'I'],
  ];
  // The conversion (happens now for ease of use but as stated earlier these
  // will be saved like this already).
  final List<ScaleDegreeProgression> _savedProgressions = _drySavedProgressions
      .map((List<String> prog) => ScaleDegreeProgression.fromList(prog))
      .toList();
  print(_savedProgressions);

  // Detect the base progressions' scale
  final List<Scale> _possibleScales = _baseChordProgression.matchWithKeys();

  // Convert the base progression to roman numerals, we used the most probable
  // scale that was detected (which would be the first in the list).
  final ScaleDegreeProgression _baseProgression =
      ScaleDegreeProgression.fromChords(
          _possibleScales[0], _baseChordProgression);
  print(_baseProgression);
  print('');

  // Sort the saved progressions based on initial match scores
  _savedProgressions.sort(
      (ScaleDegreeProgression a, ScaleDegreeProgression b) =>
          -1 *
          a
              .percentMatchedWith(_baseProgression)
              .compareTo(b.percentMatchedWith(_baseProgression)));

  // Remove the progressions with a score of 1.0 (since they exist in the
  // base progression...).
  _savedProgressions.removeWhere((ScaleDegreeProgression prog) =>
      prog.percentMatchedWith(_baseProgression) == 1.0);

  for (ScaleDegreeProgression progression in _savedProgressions) {
    print('$progression: ${progression.percentMatchedWith(_baseProgression)}'
        ' -> ${progression.getPossibleSubstitutions(_baseProgression)}');
  }
}

_test() {
  ChordList chords = ChordList([
    Chord.parse('Dm'),
    Chord.parse('G'),
    Chord.parse('C'),
  ]);

  final List<String> _chordNames =
      chords.map<String>((chord) => chord.getCommonName()).toList();

  print(_chordNames.toString() + '\n');

  final List<Scale> scales = matchChordNamesWithKey(_chordNames);
  for (Scale scale in scales) {
    print(scale.getCommonName());
    List<ScaleDegreeChord> _scaleDegreeChords = chords
        .map<ScaleDegreeChord>((chord) => ScaleDegreeChord(scale, chord))
        .toList();
    print(_scaleDegreeChords.toString() + '\n');
  }
}

extension ToStringExtension on Scale {
  String getCommonName() {
    final String scaleTonic = tonic.toString();
    final String scalePattern =
        pattern.name == 'Diatonic Major' ? 'Major' : 'Minor';
    return scaleTonic + ' ' + scalePattern;
  }
}
