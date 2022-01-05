import 'package:thoery_test/extensions/scale_extension.dart';
import 'package:thoery_test/modals/scale_degree.dart';
import 'package:thoery_test/extensions/interval_extension.dart';
import 'package:tonic/tonic.dart';

class ScaleDegreeChord {
  late final ChordPattern _pattern;

  /// The root degree from which the chord is constructed.
  /// Examples:
  /// The [rootDegree] of ii in C (Dm) is the ii scale degree (D).
  /// The [rootDegree] of ♭ii in C (Dbm) is the ♭ii scale degree (Db).
  late final ScaleDegree _rootDegree;

  /*
  TODO: Implement inversions. i.e. V4/2. Maybe take a look at this:
        https://music.stackexchange.com/questions/73537/using-roman-numeral-notation-with-notes-in-the-bass-not-figured-bass
  */

  static final RegExp chordNamePattern = RegExp(
      r"^([#b♯♭𝄪𝄫]*(?:III|II|IV|I|VII|VI|V))(.*)$",
      caseSensitive: false);

  static const List<String> _majorChordPatternNames = [
    'Major',
    'Minor',
    'Minor',
    'Major',
    'Major',
    'Minor',
    'Diminished',
  ];

  static const List<String> _major7sChordPatternNames = [
    'Major 7th',
    'Minor 7th',
    'Minor 7th',
    'Major 7th',
    'Dominant 7th',
    'Minor 7th',
    'Diminished 7♭5',
  ];

  ScaleDegreeChord(Scale scale, Chord chord) {
    _pattern = chord.pattern;
    _rootDegree =
        ScaleDegree(scale.pattern, chord.root - scale.tonic.toPitch());
  }

  ScaleDegreeChord.raw(ChordPattern pattern, ScaleDegree rootDegree)
      : _pattern = pattern,
        _rootDegree = rootDegree;

  ScaleDegreeChord.copy(ScaleDegreeChord chord)
      : _pattern = ChordPattern(
            name: chord._pattern.name,
            fullName: chord._pattern.fullName,
            abbrs: chord._pattern.abbrs,
            intervals: chord._pattern.intervals),
        _rootDegree = ScaleDegree.copy(chord._rootDegree);

  ScaleDegreeChord.parse(String chord) {
    final match = chordNamePattern.matchAsPrefix(chord);
    if (match == null) {
      throw FormatException("invalid ScaleDegreeChord name: $chord");
    }
    // If the degree is lowercased (meaning the chord contains a minor triad.
    ChordPattern _cPattern = ChordPattern.parse(match[2]!);
    if (match[1]!.toLowerCase() == match[1]) {
      // We don't want to change any of the generated chord patterns (for some
      // reason they aren't const so I can change them and screw up that entire
      // ChordPattern.
      // The ... operator de-folds the list.
      final List<Interval> _intervals = [..._cPattern.intervals];
      // TODO: Make sure this is stable.
      // Make the 2nd interval (the one between the root and the 3rd) minor.
      _intervals[1] = Interval.m3;
      _cPattern = ChordPattern.fromIntervals(_intervals);
    }
    _pattern = _cPattern;
    _rootDegree = ScaleDegree.parse(match[1]!);
  }

  ChordPattern get pattern => _pattern;

  ScaleDegree get rootDegree => _rootDegree;

  /// Returns a list of [ScaleDegree] that represents the degrees that make up
  /// the [ScaleDegreeChord] in the major scale.
  List<ScaleDegree> get degrees =>
      _pattern.intervals.map((i) => _rootDegree.add(i)).toList();

  int get degreesLength => _pattern.intervals.length;

  // FIXME: Optimize this!
  /// Returns true if the chord is diatonic in the major scale.
  bool get isDiatonic => degrees.every((degree) => degree.isDiatonic);

  bool get canBeTonic {
    final List<Interval> _intervals = _pattern.intervals;
    if ((_intervals[0] - _intervals[2]).equals(Interval.P5)) {
      final Interval third = _intervals[0] - _intervals[1];
      if (third.equals(Interval.M3) || third.equals(Interval.m3)) {
        if (_intervals.length < 4) return true;
        final Interval seventh = (_intervals[0] - _intervals[3]);
        if (seventh.equals(Interval.m7)) {
          return true;
        }
        return third.equals(Interval.M3) || seventh.equals(Interval.M7);
      }
    }
    return false;
  }

  // TODO: The other checks here might be redundant...
  bool get containsSeventh {
    if (degreesLength >= 4) {
      if (_pattern.intervals[3].number == 7) {
        return true;
      } else {
        for (int i = degreesLength - 1; i >= 0; i--) {
          if (_pattern.intervals[i].number == 7) return true;
        }
      }
    }
    return false;
  }

  // TODO: This only works for major based modes...
  /// Returns a new [ScaleDegreeChord] representing the current
  /// [ScaleDegreeChord] in a different mode (from [fromMode] to [toMode]),
  /// i.e it's mode equivalent.
  /// Ionian's (Major) mode number is 0 and so on...
  /// Example: ii.modeShift(0, 5) [major to minor] => iv.
  ScaleDegreeChord modeShift(int fromMode, int toMode) =>
      ScaleDegreeChord.raw(_pattern, rootDegree.modeShift(fromMode, toMode));

  /// Returns a new [ScaleDegreeChord] converted such that [tonic] is the new
  /// tonic. Everything is still represented in the major scale, besides to degree the function is called on...
  /// Example: V.tonicizedFor(VI) => III, I.tonicizedFor(VI) => VI,
  /// ii.tonicizedFor(VI) => vii.
  ScaleDegreeChord tonicizedFor(ScaleDegree tonic) {
    if (tonic == ScaleDegree.tonic) {
      return ScaleDegreeChord.copy(this);
    }
    return ScaleDegreeChord.raw(_pattern, rootDegree.tonicizedFor(tonic));
  }

  @override
  String toString() {
    String _rootDegreeStr = _rootDegree.toString();
    String _patternStr = _pattern.abbr;
    if (_pattern.intervals[1] == Interval.m3) {
      _rootDegreeStr = _rootDegreeStr.toLowerCase();
      switch (_pattern.name) {
        case 'Minor':
          _patternStr = '';
          break;
        case 'Min 7th':
          _patternStr = '7';
      }
    }
    return _rootDegreeStr + _patternStr;
  }

  @override
  bool operator ==(Object other) =>
      other is ScaleDegreeChord &&
      (other._pattern == _pattern && other._rootDegree == _rootDegree);

  @override
  int get hashCode => Object.hash(_pattern.fullName, _rootDegree);

  // TDC: Check if this works correctly!!
  /// Returns true if the chord is equal to [other], such that their triads + 7
  /// are equal. Tensions aren't taken into consideration.
  /// If there's no 7 in only one of the chords we treat it as if it had the
  /// relevant diatonic 7, base on the Major Scale. Meaning that in a major key
  /// a ii would be weakly equal to a ii7 but not a iimaj7.
  bool weakEqual(ScaleDegreeChord other) {
    if (_rootDegree != other._rootDegree) {
      return false;
    } else if (_pattern == other._pattern) {
      return true;
    }
    List<Interval> ownIntervals = _pattern.intervals.sublist(1, 3);
    List<Interval> otherIntervals = other._pattern.intervals.sublist(1, 3);
    for (int i = 0; i < 2; i++) {
      if (!ownIntervals[i].equals(otherIntervals[i])) return false;
    }
    if (_pattern.intervals.length >= 4) {
      if (other._pattern.intervals.length >= 4) {
        if (!_pattern.intervals[3].equals(other._pattern.intervals[3])) {
          return false;
        }
      } else {
        if (!_rootDegree.add(_pattern.intervals[3]).isDiatonic) {
          return false;
        }
      }
    } else {
      if (other._pattern.intervals.length >= 4) {
        if (!other._rootDegree.add(other._pattern.intervals[3]).isDiatonic) {
          return false;
        }
      }
    }
    return true;
  }

  // TDC: Only works for the major scale, is this correct?
  // TDC: Check if this works correctly!!
  /// Returns a hash of the chord with no tensions. 7th are hashed in if
  /// they're not diatonic (based on the major scale).
  int get weakHash {
    List<Interval> intervals = _pattern.intervals.sublist(1, 3);
    if (intervals.length >= 4) {
      if (!_rootDegree.add(_pattern.intervals[3]).isDiatonic) {
        intervals.add(_pattern.intervals[3]);
      }
    }
    return Object.hash(
        _rootDegree,
        Object.hashAll(
            [for (Interval interval in intervals) interval.getHash]));
  }

  static final ScaleDegreeChord majorTonicTriad = ScaleDegreeChord.parse('I');
}

enum HarmonicFunction {
  tonic,
  subDominant,
  dominant,
  undefined,
}
