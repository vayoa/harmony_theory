import 'package:tonic/tonic.dart';

import '../../extensions/chord_extension.dart';
import 'degree/degree.dart';
import 'degree/degree_chord.dart';

abstract class GenericChord<T> {
  late final ChordPattern _pattern;

  late final T _root;

  late final T? _bass;

  late final Interval? _bassToRoot;

  late final bool _isInversion;

  /*
  TODO: Implement inversions. i.e. V4/2. Maybe take a look at this:
        https://music.stackexchange.com/questions/73537/using-roman-numeral-notation-with-notes-in-the-bass-not-figured-bass
  */

  GenericChord(
    ChordPattern pattern,
    T root, {
    T? bass,
    Interval? bassToRoot,
    bool? isInversion,
  }) : assert((bass == null) == (bassToRoot == null)) {
    _root = root;
    _bass = bass == root ? null : bass;
    _bassToRoot = bassToRoot;
    if (_bass == null) {
      _pattern = pattern;
      _isInversion = false;
    } else {
      _pattern = _patternBassHandler(pattern, bassToRoot!);
      _isInversion = isInversion ?? _pattern.intervals.contains(bassToRoot);
    }
  }

  ChordPattern get pattern => _pattern;

  T get root => _root;

  T get bass => _bass ?? _root;

  bool get hasDifferentBass => _bass != null;

  Interval get bassToRoot => _bassToRoot ?? Interval.P1;

  /// Returns true if [bass] is a degree in the current [DegreeChord], meaning an inversion.
  ///
  /// If [bass] is the same as [root] will still return true.
  bool get isInversion => _isInversion;

  /// Returns a list of [Degree] that represents the degrees that make up
  /// the [DegreeChord] in the major scale.
  List<T> get patternMapped;

  int get patternLength => _pattern.intervals.length;

  static ChordPattern _patternBassHandler(
      ChordPattern pattern, Interval rootToBass) {
    if (rootToBass.number == 7) {
      List<Interval> intervals = pattern.intervals.sublist(0, 3);
      return ChordPattern.fromIntervals(intervals..add(rootToBass));
    }
    return pattern;
  }

  bool get requiresAddingSeventh {
    if (patternLength >= 4) {
      // If we're any of these patterns, don't consider this a 7th when
      // deciding whether to add to the whole progression a 7th when
      // substituting.
      if (_pattern.fullName != 'Dominant 7th' &&
          _pattern.fullName != 'Diminished 7th' &&
          _pattern.fullName != 'Dominant 7♭5' &&
          // Also half-diminished 7th.
          _pattern.fullName != 'Minor 7th ♭5') {
        return _pattern.intervals[3].number == 7;
      }
    }
    return false;
  }

  /// Will return a new [GenericChord] with an added 7th if possible.
  /// [harmonicFunction] can be given for slightly more relevant results.
  GenericChord addSeventh({HarmonicFunction? harmonicFunction});

  String get rootString => _root.toString();

  String get patternString {
    String patternStr = _pattern.abbr;
    if (_pattern.hasMinor3rd) {
      switch (_pattern.fullName) {
        case 'Minor':
          patternStr = '';
          break;
        case 'Minor 7th':
          patternStr = '7';
          break;
        case 'Minor-Major 7th':
        case 'Major 7th':
          patternStr = 'Δ7';
          break;
      }
    }
    return patternStr;
  }

  String get bassString => hasDifferentBass ? '/$bass' : '';

  @override
  String toString() =>
      rootString + patternString + (hasDifferentBass ? bassString : '');

  @override
  bool operator ==(Object other) =>
      other is GenericChord<T> &&
      (other._pattern.equals(_pattern) &&
          other._root == _root &&
          other._bass == _bass);

  @override
  int get hashCode => Object.hash(_pattern.fullName, _root, _bass);
}
