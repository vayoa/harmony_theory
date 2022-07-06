import 'package:harmony_theory/modals/theory_base/scale_degree/scale_degree_chord.dart';

class PairMap<T> {
  /// The computed hash map.
  ///
  /// First key is the first [ScaleDegreeChord].
  ///
  /// The key in the second map is the second [ScaleDegreeChord],
  /// and the value for that key is the value [T] returned by their pair
  /// (one after the other...).
  ///
  /// The [_hashMap] contains an int of the hash of the chord + a boolean that
  /// determines whether the hash is weak (true - [ScaleDegreeChord.weakHash]) or
  /// strong (false - [ScaleDegreeChord.hashCode]).
  /// This allows us to specify chords that would get otherwise lost in the weakHash
  /// (like a I^5 for instance).
  late final Map<int, Map<int?, T>> _hashMap;

  /// Creates a new [PairMap] where [map] will be converted to [_hashMap].
  ///
  /// The Strings given in [map] will be converted using [ScaleDegreeChord.parse].
  PairMap(Map<String, Map<T, List<String?>?>> map) {
    _hashMap = {};
    for (String first in map.keys) {
      int firstHash = _hash(ScaleDegreeChord.parse(first));
      assert(!_hashMap.containsKey(firstHash));
      _hashMap[firstHash] = {};

      assert(map[first]!.isNotEmpty);

      for (T value in map[first]!.keys) {
        if (map[first]![value] == null) {
          assert(!_hashMap[firstHash]!.containsKey(null));
          _hashMap[firstHash]![null] = value;
        } else {
          for (String? second in map[first]![value]!) {
            int? secondHash =
                second == null ? null : _hash(ScaleDegreeChord.parse(second));
            assert(!_hashMap[firstHash]!.containsKey(secondHash));
            _hashMap[firstHash]![secondHash] = value;
          }
        }
      }
    }
  }

  int _hash(ScaleDegreeChord chord) {
    if (chord.hasDifferentBass || chord.patternLength > 3) {
      return Object.hash(false, chord.hashCode);
    }
    return Object.hash(true, chord.weakHash);
  }

  int? _containedHash(ScaleDegreeChord chord, Map map) {
    // Start with the strong...
    int strong = Object.hash(false, chord.hashCode);
    if (map.containsKey(strong)) return strong;
    // If it doesn't exists check the weak...
    int weak = Object.hash(true, chord.weakHash);
    if (map.containsKey(weak)) return weak;
    // Return null if both don't exist...
    return null;
  }

  /// Returns the value for the given pair.
  T? getMatch(ScaleDegreeChord first, ScaleDegreeChord second) {
    int? firstHash = _containedHash(first, _hashMap);
    if (firstHash != null) {
      int? secondHash = _containedHash(second, _hashMap[firstHash]!);
      if (secondHash != null) {
        return _hashMap[firstHash]![secondHash];
      } else if (_hashMap[firstHash]!.containsKey(null)) {
        return _hashMap[firstHash]![null];
      }
    }
    return null;
  }

  @override
  String toString() => _hashMap.toString();
}
