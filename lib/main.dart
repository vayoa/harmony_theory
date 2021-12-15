import 'package:thoery_test/extensions/scale_extensions.dart';
import 'package:thoery_test/modals/scale_degree.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/in_scale_weight.dart';
import 'package:tonic/tonic.dart';
import 'package:thoery_test/extensions/chord_extension.dart';
import 'modals/chord_progression.dart';

void main() {
  ScaleDegreeProgression progression =
      ScaleDegreeProgression.fromList(['ii', 'V', 'I']);
  const InScaleWeight weight = InScaleWeight();
  print(weight.score(progression));
  progression = ScaleDegreeProgression.fromList(['II', 'V', 'I']);
  print(weight.score(progression));
  progression = ScaleDegreeProgression.fromList(['V', 'I']);
  progression.add(
      ScaleDegreeChord(
          Scale(
              tonic: PitchClass.parse('C'),
              pattern: ScalePattern.findByName('Diatonic Major')),
          Chord.parse('Cmaj7')),
      1 / 4);
  print(weight.score(progression));
}

_basicMatchingTest() {
  // Example use-case:
  // Base chord progression based on which we suggests chords.
  // print("Please enter your chords (enter '-' to stop):");
  List<Chord> _chords = [];
  // String? input;
  // do {
  //   input = stdin.readLineSync() ?? '';
  //   Chord _chord;
  //   try {
  //     _chord = Chord.parse(input);
  //     _chords.add(_chord);
  //   } on FormatException catch (e) {
  //     print(e);
  //   }
  // } while (input != '-');

  _chords = [
    Chord.parse('F'),
    Chord.parse('G'),
    Chord.parse('C'),
    Chord.parse('C'),
  ];

  final ChordProgression _baseChordProgression =
      ChordProgression.evenTime(_chords);
  print('Your Progression:\n$_baseChordProgression.');

  // Detect the base progressions' scale
  final List<Scale> _possibleScales = _baseChordProgression.matchWithKeys();
  print('Scale Found: ${_possibleScales[0].getCommonName()}.');

  // Convert the base progression to roman numerals, we used the most probable
  // scale that was detected (which would be the first in the list).
  final ScaleDegreeProgression _baseProgression =
      ScaleDegreeProgression.fromChords(
          _possibleScales[0], _baseChordProgression);
  print('In Roman Numerals: $_baseProgression.\n');

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

  /* TDC: I'm not sure if, for instance, a ii V I in a different rhythm than
          the user saved should only be suggested if he saved that one too, or
          if we suggest all variants. How can this even be done? Think about
          this and decide how to approach it... */
  // To demonstrate duration matching we'll add another ii V I progression but
  // with a different rhythm...
  _savedProgressions.addAll([
    ScaleDegreeProgression.fromList(['ii', 'V', 'I'], [1 / 4, 1 / 4, 1 / 2]),
    ScaleDegreeProgression.fromList(['V', 'I'], [1 / 4, 1 / 2]),
    ScaleDegreeProgression.fromList(
        ['ii', 'v', 'V', 'I'], [1 / 8, 1 / 8, 1 / 8, 1 / 2]),
  ]);

  print('Saved Progressions:\n$_savedProgressions.\n');

  // Calculate all of the possible substitutions based on the library and
  // save each one's similarity rating.
  Map<ScaleDegreeProgression, List<RatedSubstitution>> _ratedSubstitutions = {
    for (var e in _savedProgressions) e: []
  };
  for (ScaleDegreeProgression progression in _savedProgressions) {
    progression.getPossibleSubstitutions(_baseProgression).forEach(
        (ScaleDegreeProgression sub) => _ratedSubstitutions[progression]!.add(
            RatedSubstitution(sub, sub.percentMatchedTo(_baseProgression))));
  }

  // Sort the rated progressions based on their ratings, descending order...
  _ratedSubstitutions.forEach((_, value) => value.sort(
      (RatedSubstitution a, RatedSubstitution b) =>
          -1 * a.rating.compareTo(b.rating)));

  // Remove the progressions with a score of 1.0 (since they exist in the
  // base progression...).
  _ratedSubstitutions.forEach((_, value) =>
      value.removeWhere((RatedSubstitution rSub) => rSub.rating == 1.0));

  // We can also sort based on the progressions with the averagely highest
  // rated substitutions.
  final List<MapEntry<ScaleDegreeProgression, List<RatedSubstitution>>>
      _sorted = _ratedSubstitutions.entries.toList();
  _sorted.sort((a, b) =>
      -1 *
      (a.value.fold<double>(0.0,
                  (previousValue, element) => previousValue + element.rating) /
              a.value.length)
          .compareTo(b.value.fold<double>(0.0,
                  (previousValue, element) => previousValue + element.rating) /
              b.value.length));

  print('Suggestions:');
  for (MapEntry<ScaleDegreeProgression, List<RatedSubstitution>> e in _sorted) {
    String subs = '';
    for (RatedSubstitution rS in e.value) {
      subs +=
          '${rS.substitution} -> ${rS.substitution.inScale(_possibleScales[0])}:'
          ' ${rS.rating.toStringAsFixed(3)},\n';
    }
    print('-- ${e.key} --\n$subs');
  }
}

_test() {
  ChordProgression chords = ChordProgression.evenTime([
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

class RatedSubstitution {
  final ScaleDegreeProgression substitution;
  final double rating;

  const RatedSubstitution(this.substitution, this.rating);

  @override
  bool operator ==(Object other) =>
      other is RatedSubstitution &&
      substitution == other.substitution &&
      rating == other.rating;

  @override
  int get hashCode => Object.hash(substitution, rating);
}
