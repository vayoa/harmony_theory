import 'package:thoery_test/modals/scale_degree.dart';
import 'package:thoery_test/extensions/interval_extension.dart';
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

  static final Pattern chordNamePattern = RegExp(
      r"^([#b♯♭𝄪𝄫]*(?:III|II|IV|I|VII|VI|V)(?:\d*))\s*(.*)$",
      caseSensitive: false);

  ScaleDegreeChord(Scale scale, Chord chord) {
    pattern = chord.pattern;
    rootDegree = ScaleDegree(scale.pattern, chord.root - scale.tonic.toPitch());
  }

  ScaleDegreeChord.parse(ScalePattern scalePattern, String chord) {
    //TODO: Handle minor chords (meaning lowercase letters).
    final match = chordNamePattern.matchAsPrefix(chord);
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

  // TODO: This only works in major key, fix this if needed.
  List<ScaleDegree> get degreesInMajor =>
      pattern.intervals.map((i) => rootDegree.addInMajor(i)).toList();

  List<ScaleDegree> degrees(ScalePattern scalePattern) =>
      pattern.intervals.map((i) => rootDegree.add(scalePattern, i)).toList();

  // FIXME: Optimize this!
  bool isDiatonic(ScalePattern scalePattern) =>
      degrees(scalePattern).every((degree) => degree.isDiatonic);

  // ScaleDegreeChord add7() {
  //   if (pattern.intervals.length < 4 || pattern.intervals[3].)
  // }

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

  // TDC: Check if this works correctly!!
  /// Returns true if the chord is equal to [other], such that their triads + 7
  /// are equal. Tensions aren't taken into consideration.
  /// If there's no 7 in only one of the chords we treat it as if it had the
  /// relevant diatonic 7, base on [scalePattern]. Meaning that in a major key
  /// a ii would be weakly equal to a ii7 but not a iimaj7.
  bool weakEqual(ScalePattern scalePattern, ScaleDegreeChord other) {
    if (rootDegree != other.rootDegree) return false;
    List<Interval> ownIntervals = pattern.intervals.sublist(1, 3);
    List<Interval> otherIntervals = other.pattern.intervals.sublist(1, 3);
    for (int i = 0; i < 2; i++) {
      if (!ownIntervals[i].equals(ownIntervals[i])) return false;
    }
    if (pattern.intervals.length >= 4) {
      if (other.pattern.intervals.length >= 4) {
        if (!pattern.intervals[3].equals(other.pattern.intervals[3])) {
          return false;
        }
      } else {
        if (!rootDegree.add(scalePattern, pattern.intervals[3]).isDiatonic) {
          return false;
        }
      }
    } else {
      if (other.pattern.intervals.length >= 4) {
        if (!other.rootDegree
            .add(scalePattern, other.pattern.intervals[3])
            .isDiatonic) {
          return false;
        }
      }
    }
    return true;
  }

  // TDC: Check if this works correctly!!
  /// Returns a hash of the chord with no tensions. 7th are hashed in if
  /// they're not diatonic (based on [scalePattern]).
  int weakHash(ScalePattern scalePattern) {
    List<Interval> intervals = pattern.intervals.sublist(1, 3);
    if (intervals.length >= 4) {
      if (!rootDegree.add(scalePattern, pattern.intervals[3]).isDiatonic) {
        intervals.add(pattern.intervals[3]);
      }
    }
    return Object.hash(rootDegree,
        Object.hashAll([for (Interval interval in intervals) interval.hashEx]));
  }
}

enum HarmonicFunction {
  tonic,
  subDominant,
  dominant,
  undefined,
}
