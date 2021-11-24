import 'package:thoery_test/modals/scale_degree.dart';
import 'package:tonic/tonic.dart';

class ScaleDegreeChord {
  late final ChordPattern pattern;

  /// The root degree from which the chord is constructed.
  /// Examples:
  /// The [rootDegree] of ii in C (Dm) is the ii scale degree (D).
  /// The [rootDegree] of ♭ii in C (Dbm) is the ♭ii scale degree (Db).
  late final ScaleDegree rootDegree;

  /*
  TODO: Implement inversions. i.e. V4/2. Maybe take a look at this:
        https://music.stackexchange.com/questions/73537/using-roman-numeral-notation-with-notes-in-the-bass-not-figured-bass
  */
  String inversion = '';

  static final Pattern cordNamePattern = RegExp(
      r"^([#b♯♭𝄪𝄫]*(?:III|II|IV|I|VII|VI|V)(?:\d*))\s*(.*)$",
      caseSensitive: false);

  ScaleDegreeChord(Scale scale, Chord chord) {
    pattern = chord.pattern;
    rootDegree = ScaleDegree(scale.pattern, chord.root - scale.tonic.toPitch());
  }

  ScaleDegreeChord.parse(String chord) {
    //TODO: Handle minor chords (meaning lowercase letters).
    final match = cordNamePattern.matchAsPrefix(chord);
    if (match == null) {
      throw FormatException("invalid ScaleDegreeChord name: $chord");
    }
    // If the degree is lowercased (meaning the chord contains a minor triad.
    ChordPattern _pattern = ChordPattern.parse(match[2]!);
    if (match[1]!.toLowerCase() == match[1]) {
      // We don't want to change any of the generated chord patterns (for some
      // reason they aren't const so I can change them and screw up that entire
      // ChordPattern.
      // The ... operator de-folds the list.
      final List<Interval> _intervals = [..._pattern.intervals];
      // TODO: Make sure this is stable.
      // Make the 2nd interval (the one between the root and the 3rd) minor.
      _intervals[1] = Interval.m3;
      _pattern = ChordPattern.fromIntervals(_intervals);
    }
    pattern = _pattern;
    rootDegree = ScaleDegree.parse(match[1]!);
  }

  @override
  String toString() {
    String _rootDegreeStr = rootDegree.toString();
    String _patternStr = pattern.abbr;
    if (pattern.intervals[1] == Interval.m3) {
      _rootDegreeStr = _rootDegreeStr.toLowerCase();
      if (pattern.name == 'Minor') _patternStr = '';
    }
    return _rootDegreeStr + _patternStr;
  }

  @override
  bool operator ==(Object other) =>
      other is ScaleDegreeChord &&
      (other.pattern == pattern && other.rootDegree == rootDegree);

  @override
  int get hashCode => Object.hash(pattern.fullName, rootDegree);
}
