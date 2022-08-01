part of 'progression_bank.dart';

/* TODO: Maybe filter these by equal tonicizations (there might
    be duplicates here in terms of tonicizations).
 */
// AY: These need to be titled :/
// AY: Some of these have more than 8 chords, should we change that restriction?
// AY: You wrote ^6 on a couple of those, what to do there with tonicization?
final Map<String, DegreeProgression> _inversionProgressions = {
  'Inversions 1': DegreeProgression.parse('I, VI^3, ii'),
  'Inversions 2': DegreeProgression.parse('I, V^3, I'),
  'Inversions 3': DegreeProgression.parse('vi, III^3, vi'),
  'Inversions 4': DegreeProgression.parse('I, V^5, I^3'),
  'Inversions 5': DegreeProgression.parse('I, vii°^3, I^3'),
  'Inversions 6': DegreeProgression.parse('vi, V^3, I'),
  'Inversions 7': DegreeProgression.parse('vi, III^5, vi^3'),
  'Inversions 8': DegreeProgression.parse('vi, III^5, vi^3, ii, III'),
  'Inversions 9': DegreeProgression.parse('vi, V^3, vi^3, ii, vi^5, III, vi'),
  'Inversions 10': DegreeProgression.parse('V, V7^7, I^3'),
  'Inversions 11': DegreeProgression.parse('IV, V7^7, I^3'),
  'Inversions 12': DegreeProgression.parse('ii^3, V7^7, I^3'),
  'Inversions 13': DegreeProgression.parse('V7^7, I^3'),
  'Inversions 14': DegreeProgression.parse('III7^7, vi^3'),
  'Inversions 15': DegreeProgression.parse('ii, III7^7, vi^3'),
  'Inversions 16': DegreeProgression.parse('viiø^3, III7^7, vi^3'),
  'Inversions 17': DegreeProgression.parse('I, VI^3, ii, VII^3, III'),
  'Inversions 18': DegreeProgression.parse(
      'I, VI^3, ii, VII^3, III, IV, II^3, V, III^3, vi'),
  'Inversions 19': DegreeProgression.parse('vi, III^3, I^5, II^3, IV, III, vi'),
  'Inversions 20':
      DegreeProgression.parse('vi, viΔ7^7, vi7^7, vi^6, IV, III, vi'),
  'Inversions 21': DegreeProgression.parse('vi, viΔ7^7, vi7^7, vi^6, IV, III'),
  'Inversions 22': DegreeProgression.parse('I, Imaj7^7, iiiø^5, VI, ii'),
  'Inversions 23':
      DegreeProgression.parse('I, Imaj7^7, iiiø^5, VI, ii, ii7^7, ii^6, III'),
  'Inversions 24': DegreeProgression.parse('I, Imaj7^7, I^6, I^5, IV'),
  'Inversions 25':
      DegreeProgression.parse('I, Imaj7^7, I^6, I^5, IV, I^3, ii, V, I'),
  'Inversions 26': DegreeProgression.parse('ii^3, V, I'),
  'Inversions 27': DegreeProgression.parse('I^5, V, I'),
  'Inversions 28': DegreeProgression.parse('vi^5, III, vi'),
  'Inversions 29': DegreeProgression.parse('IV, II^3, V'),
  'Inversions 30': DegreeProgression.parse('V, III^3, vi'),
  'Inversions 31': DegreeProgression.parse('I, V^5, I^3, IV, V, I'),
  'Inversions 32': DegreeProgression.parse('ii7^7, V^3, I'),
  'Inversions 33': DegreeProgression.parse('IV^3, III^3, vi'),
  'Inversions 34': DegreeProgression.parse('VII^3, III'),
  'Inversions 35': DegreeProgression.parse('VII^3, III, vi'),
  'Inversions 36': DegreeProgression.parse('II^3, V, I'),
  'Inversions 37': DegreeProgression.parse('II^3, V'),
  'Inversions 38': DegreeProgression.parse('V, vi7, V^3'),
  'Inversions 39': DegreeProgression.parse('I, ii7, I^3'),
  'Inversions 40': DegreeProgression.parse('vi, viiø, vi^3'),
  'Inversions 41': DegreeProgression.parse('II^3, III^3, vi'),
  'Inversions 42': DegreeProgression.parse('IV^3, V^3, I'),
};
