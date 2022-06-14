import 'dart:convert';

import 'package:tonic/tonic.dart';

import '../../extensions/chord_extension.dart';
import '../identifiable.dart';
import 'scale_degree/scale_degree.dart';
import 'scale_degree/scale_degree_chord.dart';

abstract class GenericChord<T extends Identifiable> implements Identifiable {
  late final ChordPattern _pattern;

  late final T _root;

  /*
  TODO: Implement inversions. i.e. V4/2. Maybe take a look at this:
        https://music.stackexchange.com/questions/73537/using-roman-numeral-notation-with-notes-in-the-bass-not-figured-bass
  */

  GenericChord(this._pattern, this._root);

  ChordPattern get pattern => _pattern;

  T get root => _root;

  /// Returns a list of [ScaleDegree] that represents the degrees that make up
  /// the [ScaleDegreeChord] in the major scale.
  List<T> get patternMapped;

  int get patternLength => _pattern.intervals.length;

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
    String _patternStr = _pattern.abbr;
    if (_pattern.hasMinor3rd) {
      switch (_pattern.fullName) {
        case 'Minor':
          _patternStr = '';
          break;
        case 'Minor 7th':
          _patternStr = '7';
          break;
        case 'Minor-Major 7th':
        case 'Major 7th':
          _patternStr = 'Δ7';
          break;
      }
    }
    return _patternStr;
  }

  @override
  String toString() {
    return rootString + patternString;
  }

  @override
  bool operator ==(Object other) =>
      other is GenericChord<T> &&
      (other._pattern.equals(_pattern) && other._root == _root);

  @override
  int get hashCode => Object.hash(_pattern.fullName, _root);

  @override
  int get id => Identifiable.hash2(
      Identifiable.hashAllInts(utf8.encode(_pattern.fullName)), _root.id);
}
