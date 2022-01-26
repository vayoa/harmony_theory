import 'package:thoery_test/extensions/scale_extension.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:thoery_test/state/substitution_handler.dart';
import 'package:tonic/tonic.dart';
import 'modals/chord_progression.dart';
import 'modals/substitution.dart';

void main() {
  ScaleDegreeProgression prog = ScaleDegreeProgression.fromChords(
    Scale(
        pattern: ScalePattern.findByName("Diatonic Major"),
        tonic: PitchClass.parse('C')),
    ChordProgression.evenTime(
      [
        Chord.parse('B°'),
        Chord.parse('E'),
        Chord.parse('Am'),
        Chord.parse('Em'),
        Chord.parse('A'),
        Chord.parse('Dm'),
        Chord.parse('G'),
        Chord.parse('C'),
        Chord.parse('F'),
        Chord.parse('G'),
        Chord.parse('C'),
      ],
    ),
  );
  print(prog);

  prog.deriveTonicizations;
}

_test() {
  // // InScaleWeight
  // ScaleDegreeProgression progression =
  //     ScaleDegreeProgression.fromList(['ii', 'V', 'I']);
  // const InScaleWeight weight = InScaleWeight();
  // print(weight.score(progression));
  // progression = ScaleDegreeProgression.fromList(['II', 'V', 'I']);
  // print(weight.score(progression));
  // progression = ScaleDegreeProgression.fromList(['V', 'I']);
  // progression.add(
  //     ScaleDegreeChord(
  //         Scale(
  //             tonic: PitchClass.parse('C'),
  //             pattern: ScalePattern.findByName('Diatonic Major')),
  //         Chord.parse('Cmaj7')),
  //     1 / 4);
  // print(weight.score(progression));

  // // UniquesWeight
  // ScaleDegreeProgression progression =
  //     ScaleDegreeProgression.fromList(['ii', 'V', 'I', 'II', 'I']);
  // const UniquesWeight weight = UniquesWeight();
  // print(weight.score(progression));
  // // Remember that the extra chords here get joined together...
  // progression =
  //     ScaleDegreeProgression.fromList(['ii', 'V', 'V', 'V', 'V', 'V', 'I']);
  // print(weight.score(progression));
  // progression =
  //     ScaleDegreeProgression.fromList(['ii', 'I', 'II', 'V', 'v', 'V', 'VI']);
  // print(weight.score(progression));

  // // OvertakingWeight
  // const OvertakingWeight overtakingWeight = OvertakingWeight();
  // const UniquesWeight uniquesWeight = UniquesWeight();
  // ScaleDegreeProgression progression =
  //     ScaleDegreeProgression.fromList(['ii7', 'I', 'ii', 'I']);
  // print(overtakingWeight.score(progression));
  // print(uniquesWeight.score(progression));

  // ScaleDegreeProgression prog =
  //     ScaleDegreeProgression.fromList(['ii7', 'V7', 'I']);
  // print(prog);
  // print(prog.modeShift(toMode: 5));

  // print(ScaleDegreeProgression.fromList(['ii', 'V', 'I'],
  //     durations: [1 / 4, 1 / 4, 1 / 2]));

  // ScaleDegreeProgression base = ScaleDegreeProgression.fromList(
  //     ['II', 'III', 'vi'],
  //     durations: [1 / 2, 1 / 2, 2]);
  // print(base);
  // print(base.duration);
  // ScaleDegreeProgression sub = ScaleDegreeProgression.fromList(
  //     ['vii°', 'III', 'VI', 'vi', 'vi'],
  //     durations: [1 / 2, 1 / 2, 1 / 2, 1 / 2, 1]);
  // print(sub);
  // print(sub.duration);
  // print(sub.percentMatchedTo(base));

  // ScaleDegreeProgression base =
  //     ScaleDegreeProgression.fromList(['IV', 'ii', 'V', 'I']);
  // print(base);
  // ScaleDegreeProgression bank =
  //     ScaleDegreeProgression.fromList(['ii', 'V', 'I']);
  // print(bank);
  // print(base.getPossibleSubstitutions(bank));

  ProgressionBank bank = ProgressionBank();
  // Chords for "יונתן הקטן".
  ChordProgression base = ChordProgression(
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
  // SubstitutionHandler.test(
  //   base: base,
  //   bank: bank,
  // );
  Substitution sub = SubstitutionHandler.substituteBy(
    base: base,
    bank: bank,
    maxIterations: 50,
  );
  print(sub.substitutedBase.deriveHarmonicFunctions);
  // Substitution sub = SubstitutionHandler.perfectSubstitution(
  //     base: base, bank: bank, maxIterations: 1000);
  // for (ScaleDegreeChord? chord in sub.substitutedBase.values) {
  //   if (chord != null) {
  //     print('$chord: ' +
  //         chord
  //             .deriveHarmonicFunction(inMinor: sub.substitutedBase.inMinor)
  //             .name);
  //   }
  // }

  // _basicMatchingTest();
}

_basicMatchingTest({bool inputChords = false}) {
  // Example use-case:
  // Base chord progression based on which we suggests chords.

  ChordProgression _baseChordProgression;
  if (inputChords) {
    _baseChordProgression = SubstitutionHandler.inputChords();
  } else {
    _baseChordProgression = ChordProgression.evenTime(
      [
        Chord.parse('F'),
        Chord.parse('G'),
        Chord.parse('C'),
        Chord.parse('C'),
      ],
    );
  }

  print('Your Progression:\n$_baseChordProgression.');

  // Detect the base progressions' scale
  final List<Scale> _possibleScales = _baseChordProgression.matchWithScales();
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
    ScaleDegreeProgression.fromList(['V', 'I'], durations: [1 / 4, 1 / 2]),
    ScaleDegreeProgression.fromList(['ii', 'V', 'I'],
        durations: [1 / 4, 1 / 4, 1 / 2]),
    ScaleDegreeProgression.fromList(['ii', 'v', 'V', 'I'],
        durations: [1 / 8, 1 / 8, 1 / 8, 1 / 2]),
  ]);

  // And another one to demonstrate null values in a banked progression.
  // Granted, this shouldn't really happen in a real case scenario (as it will
  // try to match any chord and replace the previous with a V...).
  _savedProgressions.add(ScaleDegreeProgression.fromList(['V', null]));

  // To demonstrate different modes matching we'll add another ii V I
  // progression but in a minor scale...
  _savedProgressions
      .add(ScaleDegreeProgression.fromList(['iidim', 'V', 'i'], inMinor: true));

  print('Saved Progressions:\n$_savedProgressions.\n');

  // Calculate all of the possible substitutions based on the library and
  // save each one's similarity rating.
  Map<ScaleDegreeProgression, List<RatedSubstitution>> _ratedSubstitutions = {};
  for (ScaleDegreeProgression progression in _savedProgressions) {
    List<ScaleDegreeProgression> subs = _baseProgression
        .getPossibleSubstitutions(progression)
        .map((e) => e.substitutedBase)
        .toList();
    for (var sub in subs) {
      final RatedSubstitution rs =
          RatedSubstitution(sub, sub.percentMatchedTo(_baseProgression));
      if (_ratedSubstitutions.containsKey(progression)) {
        _ratedSubstitutions[progression]!.add(rs);
      } else {
        _ratedSubstitutions[progression] = [rs];
      }
    }
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
    print('-- ${e.key} --\ndurations: ${e.key.durations}.\n'
        'base: $_baseProgression.\n$subs');
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
