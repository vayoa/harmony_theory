import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';

class DefaultBank {
  static final Map<int, ScaleDegreeProgression> _bank = {};

  /// Notice: if the major tonic is in the last place it will be saved in a
  /// different group then if it's in any other place (for tonicization).
  static final Map<int, List<int>> _groupedBank = {};

  DefaultBank([List<ScaleDegreeProgression>? additionalProgressions]) {
    if (additionalProgressions != null && additionalProgressions.isNotEmpty) {
      _bankList.addAll(additionalProgressions);
    }

    for (ScaleDegreeProgression progression in _bankList) {
      int hash = progression.hashCode;
      _bank[hash] = progression;
      for (int i = 0; i < progression.length; i++) {
        ScaleDegreeChord? chord = progression[i];
        final Map<int, ScaleDegreeChord> addedChords = {};
        if (chord != null) {
          int weakChordHash =
              weakHashWithPlace(chord, i == progression.length - 1);
          if (!addedChords.containsKey(weakChordHash)) {
            addedChords[weakChordHash] = chord;
            if (_groupedBank.containsKey(weakChordHash)) {
              _groupedBank[weakChordHash]!.add(hash);
            } else {
              _groupedBank[weakChordHash] = [hash];
            }
          }
        }
      }
    }
  }

  Map<int, ScaleDegreeProgression> get bank => _bank;

  Map<int, List<int>> get groupedBank => _groupedBank;

  @override
  String toString() {
    String output = '{';
    for (MapEntry<int, List<int>> entry in _groupedBank.entries) {
      output += '${entry.key}:\n';
      for (int hash in entry.value) {
        output += '${_bank[hash]},\n';
      }
      output += '\n';
    }
    return output + '}';
  }

  /* TODO: Decide whether to put this method here and whether to always hash
          'last'...*/

  /// [last] will only have effect when [chord.weakHash] is equal to
  /// [ScaleDegreeChord.majorTonicTriad]'s weak hash.
  static int weakHashWithPlace(ScaleDegreeChord chord, [bool last = false]) {
    int weakHash = chord.weakHash;
    if (weakHash == ScaleDegreeChord.majorTonicTriad.weakHash) {
      return Object.hash(weakHash, last);
    }
    return weakHash;
  }

  /// If [chord] is a major tonic and [last] is false, all saved progressions
  /// with a major tonic (including one that have them as their last chords)
  /// will be returned.
  List<ScaleDegreeProgression>? getByGroup(ScaleDegreeChord chord,
      [bool last = false]) {
    List<int>? hashes = _groupedBank[weakHashWithPlace(chord, last)];
    if (hashes != null) {
      hashes = [...hashes];
      // TODO: Optimize...
      int weakHash = chord.weakHash;
      if (!last && weakHash == ScaleDegreeChord.majorTonicTriad.weakHash) {
        List<int>? otherTonic = _groupedBank[Object.hash(weakHash, true)];
        if (otherTonic != null && otherTonic.isNotEmpty) {
          hashes.addAll(otherTonic);
        }
      }
      return [for (int hash in hashes) _bank[hash]!];
    }
    return null;
  }

  static final List<ScaleDegreeProgression> _bankList = [
    ScaleDegreeProgression.fromList(['ii', 'V', 'I']),
    ScaleDegreeProgression.fromList(['I', 'vi']),
    ScaleDegreeProgression.fromList(['IV', 'V', 'I']),
    ScaleDegreeProgression.fromList(['V', 'I']),
    ScaleDegreeProgression.fromList(['IV', 'iv', 'I']),
    ScaleDegreeProgression.fromList(['IV', 'I']),
    ScaleDegreeProgression.fromList(['iv', 'I']),
    ScaleDegreeProgression.fromList(['V', 'I'], durations: [1 / 4, 1 / 2]),
    ScaleDegreeProgression.fromList(['ii', 'V', 'I'],
        durations: [1 / 4, 1 / 4, 1 / 2]),
    ScaleDegreeProgression.fromList(['ii', 'v', 'V', 'I'],
        durations: [1 / 8, 1 / 8, 1 / 8, 1 / 2]),
    ScaleDegreeProgression.fromList(['iidim', 'V', 'i'], inMinor: true)
  ];
}
