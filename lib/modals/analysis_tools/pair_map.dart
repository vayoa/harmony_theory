import '../theory_base/scale_degree/scale_degree_chord.dart';
import '../theory_base/scale_degree/tonicized_scale_degree_chord.dart';

class PairMap<T> {
  /// The computed hash map.
  ///
  /// First key is the first [ScaleDegreeChord].
  ///
  /// The key in the second map is the second [ScaleDegreeChord],
  /// and the value for that key is the value [T] returned by their pair
  /// (one after the other...).
  ///
  /// The [_hashMap] contains an int of the hash of the chord.
  /// The [ScaleDegreeChord.weakHash] of it if it contains it, otherwise the regular
  /// [ScaleDegreeChord.hashCode].
  /// This allows us to specify chords that would get otherwise lost in the weakHash
  /// (like a I^5 for instance).
  late final Map<int, Map<int?, T>> _hashMap;

  Map<int, Map<int?, T>> get hashMap => _hashMap;

  /// Creates a new [PairMap] where [map] will be converted to [_hashMap].
  ///
  /// The Strings given in [map] will be converted using [ScaleDegreeChord.parse].
  PairMap(Map<String, Map<T, List<String>?>> map) {
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

  // TODO: Optimize, we're always hashing twice...
  int _hash(ScaleDegreeChord chord) {
    int weak = chord.weakHash, strong = chord.hashCode;
    if (weak == strong) return weak;
    return strong;
  }

  int? _containedHash(ScaleDegreeChord chord, Map map) {
    // Start with the strong...
    int strong = chord.hashCode;
    if (map.containsKey(strong)) return strong;
    // If it doesn't exists check the weak...
    int weak = chord.weakHash;
    if (map.containsKey(weak)) return weak;
    // Return null if both don't exist...
    return null;
  }

  ScaleDegreeChord prepareForCheck(
      ScaleDegreeChord chord, ScaleDegreeChord other) {
    if (chord is TonicizedScaleDegreeChord &&
        other is TonicizedScaleDegreeChord) {
      if (chord.tonic.root == other.tonic.root) {
        return chord.tonicizedToTonic;
      } else {
        return chord;
      }
    } else if (other is TonicizedScaleDegreeChord &&
        other.tonic.weakEqual(chord)) {
      return ScaleDegreeChord.majorTonicTriad;
    } else if (chord is TonicizedScaleDegreeChord &&
        chord.tonic.weakEqual(other)) {
      return chord.tonicizedToTonic;
    } else {
      return chord;
    }
  }

  /// Returns the value for the given pair.
  ///
  /// [useTonicizations] determines whether in case both chords are
  /// tonicized to the same tonic, we'll take their tonicizedToTonic
  /// counterparts.
  T? getMatch(
    ScaleDegreeChord first,
    ScaleDegreeChord? second, {
    bool useTonicizations = true,
  }) {
    if (second == null) return defaultFor(first);
    if (useTonicizations) {
      var tempFirst = prepareForCheck(first, second);
      second = prepareForCheck(second, first);
      first = tempFirst;
    }
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

  T? defaultFor(ScaleDegreeChord chord) =>
      _hashMap[_containedHash(chord, _hashMap)]?[null];

  @override
  String toString() => _hashMap.toString();
}
