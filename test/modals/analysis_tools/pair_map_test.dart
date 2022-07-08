import 'package:harmony_theory/modals/analysis_tools/pair_map.dart';
import 'package:harmony_theory/modals/theory_base/scale_degree/degree_chord.dart';
import 'package:test/test.dart';

main() {
  group('getMatch()', () {
    DegreeChord other = DegreeChord.majorTonicTriad;

    // Create a PairMap. Add a ii, ii7, iimaj7. Add a iii and a V as well.
    Map<String, Map<int, List<String>>> map = {
      'ii': {
        1: [other.toString()]
      },
      'ii7': {
        2: [other.toString()]
      },
      'iimaj7': {
        3: [other.toString()]
      },
      'iii': {
        4: [other.toString()]
      },
      'V': {
        5: [other.toString()],
      }
    };

    final Map<int?, List<String>> expected = {
      // Make sure that inputting ii and ii^3 go to the ii...
      1: ['ii', 'ii^3'],
      // ii7 goes to the ii7...
      2: ['ii7'],
      // and iimaj7 goes to iimaj7.
      3: ['iimaj7'],
      // Make sure that inputting iii, iii7, iii^3, iii^5 go to the iii.
      4: ['iii', 'iii7', 'iii^3', 'iii^5'],
      // Make sure that inputting V7 goes to the V...
      5: ['V', 'V7'],
      // and Vmaj7 returns null.
      null: ['Vmaj7'],
    };

    test(
      'First Keys',
      () {
        PairMap<int> pairMap = PairMap(map);
        _getMatchTester<int>(
          first: true,
          pairMap: pairMap,
          other: other,
          expected: expected,
        );
      },
    );

    test(
      'Second Keys',
      () {
        // Switch the pairMap and test the other keys.
        PairMap<int> pairMap = PairMap({
          other.toString(): {
            for (String chord in map.keys) map[chord]!.keys.first: [chord],
          },
        });

        _getMatchTester<int>(
          first: false,
          pairMap: pairMap,
          other: other,
          expected: expected,
        );
      },
    );
  });

  test('getMatch() null', () {
    DegreeChord other = DegreeChord.parse('IV');
    PairMap<int> pairMap = PairMap({
      other.toString(): {
        0: null,
        1: ['ii'],
        2: ['viidim'],
      },
    });
    _getMatchTester<int>(
      first: false,
      pairMap: pairMap,
      other: other,
      expected: {
        0: ['II', 'ii^2'],
        1: ['ii', 'ii^3', 'ii^5', 'ii7'],
        2: ['viidim', 'vii7b5'],
      },
    );
  });
}

_getMatchTester<T>({
  required bool first,
  required PairMap<T> pairMap,
  required DegreeChord other,
  required Map<T?, List<String>> expected,
}) {
  final Map<T?, List<DegreeChord>> realExpected = expected.map(
    (key, value) => MapEntry(
        key, value.map((e) => DegreeChord.parse(e)).toList(growable: false)),
  );
  for (T? val in expected.keys) {
    for (DegreeChord chord in realExpected[val]!) {
      _Pair pair = _Pair(chord, other);
      expect(
        first ? pair : pair.swap,
        _GottenMatch(val, pairMap: pairMap),
      );
    }
  }
}

class _Pair {
  final DegreeChord first;
  final DegreeChord second;

  const _Pair(this.first, this.second);

  _Pair get swap => _Pair(second, first);

  @override
  String toString() => '$first -> $second';
}

class _GottenMatch<T> extends CustomMatcher {
  final PairMap<T> pairMap;

  _GottenMatch(
    Object? valueOrMatcher, {
    required this.pairMap,
  }) : super(
          "PairMap returns a match that is",
          "match",
          valueOrMatcher,
        );

  @override
  Object? featureValueOf(actual) =>
      pairMap.getMatch((actual as _Pair).first, actual.second);
}
