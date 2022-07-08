import '../theory_base/scale_degree/degree_chord.dart';
import '../theory_base/scale_degree/tonicized_degree_chord.dart';

class PairMap<T> {
  /// The computed hash map.
  ///
  /// First key is the first [DegreeChord].
  ///
  /// The key in the second map is the second [DegreeChord],
  /// and the value for that key is the value [T] returned by their pair
  /// (one after the other...).
  ///
  /// The [_hashMap] contains an int of the hash of the chord.
  /// The [DegreeChord.weakHash] of it if it contains it, otherwise the regular
  /// [DegreeChord.hashCode].
  /// This allows us to specify chords that would get otherwise lost in the weakHash
  /// (like a I^5 for instance).
  late final Map<int, Map<int?, T>> _hashMap;

  Map<int, Map<int?, T>> get hashMap => _hashMap;

  /// Creates a new [PairMap] where [map] will be converted to [_hashMap].
  ///
  /// The Strings given in [map] will be converted using [DegreeChord.parse].
  PairMap(Map<String, Map<T, List<String>?>> map) {
    _hashMap = {};
    for (String first in map.keys) {
      int firstHash = _hash(DegreeChord.parse(first));
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
                second == null ? null : _hash(DegreeChord.parse(second));
            assert(!_hashMap[firstHash]!.containsKey(secondHash));
            _hashMap[firstHash]![secondHash] = value;
          }
        }
      }
    }
  }

  // TODO: Optimize, we're always hashing twice...
  int _hash(DegreeChord chord) {
    int weak = chord.weakHash, strong = chord.hashCode;
    if (weak == strong) return weak;
    return strong;
  }

  int? _containedHash(DegreeChord chord, Map map) {
    // Start with the strong...
    int strong = chord.hashCode;
    if (map.containsKey(strong)) return strong;
    // If it doesn't exists check the weak...
    int weak = chord.weakHash;
    if (map.containsKey(weak)) return weak;
    // Return null if both don't exist...
    return null;
  }

  DegreeChord prepareForCheck(DegreeChord chord, DegreeChord other) {
    if (chord is TonicizedDegreeChord && other is TonicizedDegreeChord) {
      if (chord.tonic.root == other.tonic.root) {
        return chord.tonicizedToTonic;
      } else {
        return chord;
      }
    } else if (other is TonicizedDegreeChord && other.tonic.weakEqual(chord)) {
      return DegreeChord.majorTonicTriad;
    } else if (chord is TonicizedDegreeChord && chord.tonic.weakEqual(other)) {
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
    DegreeChord first,
    DegreeChord? second, {
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

  T? defaultFor(DegreeChord chord) =>
      _hashMap[_containedHash(chord, _hashMap)]?[null];

  @override
  String toString() => _hashMap.toString();
}
