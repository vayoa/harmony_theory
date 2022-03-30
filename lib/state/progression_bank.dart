import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';

// TDC: Decide if this stays static or not, since it has a constructor...
class ProgressionBank {
  static final Map<int, ScaleDegreeProgression> _bank = {};

  /// Notice: if the major tonic is in the last place it will be saved in a
  /// different group then if it's in any other place (for tonicization).
  static final Map<int, List<int>> _groupedBank = {};

  static final int tonicizationHash =
      Object.hash(ScaleDegreeChord.majorTonicTriad.weakHash, true);

  /// Returns all saved progressions that have a
  /// [ScaleDegreeChord.majorTonicTriad] as their last chord.
  static List<ScaleDegreeProgression> get tonicizations {
    if (_groupedBank.containsKey(tonicizationHash)) {
      return [for (int hash in _groupedBank[tonicizationHash]!) _bank[hash]!];
    }
    return const [];
  }

  ProgressionBank([List<ScaleDegreeProgression>? additionalProgressions]) {
    if (additionalProgressions != null && additionalProgressions.isNotEmpty) {
      _bankList.addAll(additionalProgressions);
    }

    // TODO: Make sure no two same hashes are in a list in _groupedBank.
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

  /// Returns all saved progressions from [_bank] containing the
  /// [ScaleDegreeChord.weakHash] of [chord].
  /// If [withTonicization] is true, returns also all saved progressions that
  /// have a [ScaleDegreeChord.majorTonicTriad] as their last chord.
  List<ScaleDegreeProgression>? getByGroup(
      {required ScaleDegreeChord chord, required bool withTonicization}) {
    List<int>? hashes = _groupedBank[weakHashWithPlace(chord, false)];
    if (hashes != null) {
      if (withTonicization && _groupedBank.containsKey(tonicizationHash)) {
        // TODO: Optimize...
        hashes.addAll(_groupedBank[tonicizationHash]!);
      }
      return [for (int hash in hashes) _bank[hash]!];
    }
    return null;
  }

  static final List<ScaleDegreeProgression> _bankList = [
    ScaleDegreeProgression.fromList(['V', 'vi']),
    // V I
    ScaleDegreeProgression.fromList(['V', 'I']),
    ScaleDegreeProgression.fromList(['V', 'I'], durations: [1 / 4, 1 / 2]),
    // ii V I
    ScaleDegreeProgression.fromList(['ii', 'V', 'I']),
    ScaleDegreeProgression.fromList(['ii', 'V', 'I'],
        durations: [1 / 4, 1 / 4, 1 / 2]),
    ScaleDegreeProgression.fromList(['viidim', 'iii', 'III', 'vi'],
        durations: [1 / 4, 1 / 4, 1 / 4, 1 / 4]),
    ScaleDegreeProgression.fromList(['iidim', 'V', 'I']),
    ScaleDegreeProgression.fromList(['iim7b5', 'V', 'I']),
    ScaleDegreeProgression.fromList(['iim7b5', 'V7', 'Imaj7']),
    // IV V I
    ScaleDegreeProgression.fromList(['IV', 'V', 'I']),
    ScaleDegreeProgression.fromList(['IV', 'iv', 'I']),
    // IV I
    ScaleDegreeProgression.fromList(['IV', 'I']),
    ScaleDegreeProgression.fromList(['iv', 'I']),
    // Added
    ScaleDegreeProgression.fromList(['iii', 'III', 'vi']),
    ScaleDegreeProgression.fromList(['iii', 'III', 'vi', 'vi']),
    ScaleDegreeProgression.fromList(['iim7b5', 'I']),
    ScaleDegreeProgression.fromList(['iidim', 'I']),
    ScaleDegreeProgression.fromList(['IV', 'II', 'V', 'III', 'vi']),
    ScaleDegreeProgression.fromList(['vi', 'III', 'V', 'II', 'IV']),
    ScaleDegreeProgression.fromList(['bVII', 'V', 'I']),
    ScaleDegreeProgression.fromList(['bVI', 'IV', 'bVII', 'V', 'I']),
    ScaleDegreeProgression.fromList(['I', 'IV', 'I']),
    ScaleDegreeProgression.fromList(['I', 'iv', 'I']),
    ScaleDegreeProgression.fromList(['bII', 'V', 'I']),
    ScaleDegreeProgression.fromList(['bVII', 'VIIdim7', 'I']),
    ScaleDegreeProgression.fromList(['VIIdim7', 'I']),
    ScaleDegreeProgression.fromList(['bII7', 'I']),
    ScaleDegreeProgression.fromList(['iimin7', 'bII7', 'I']),
    ScaleDegreeProgression.fromList(['iim7b5', 'bII7', 'I']),
    ScaleDegreeProgression.fromList(['bVI', 'bVII', 'I']),
    ScaleDegreeProgression.fromList(['bVII', 'I']),
    ScaleDegreeProgression.fromList(['Vaug', 'I']),
    ScaleDegreeProgression.fromList(['iv', 'V', 'I']),
  ];
}
