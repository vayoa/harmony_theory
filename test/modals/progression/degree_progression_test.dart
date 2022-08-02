import 'package:harmony_theory/modals/progression/degree_progression.dart';
import 'package:harmony_theory/modals/substitution_match.dart';
import 'package:test/test.dart';

main() {
  group('Cut Range', () {
    late final DegreeProgression base;
    late final DegreeProgression sub;
    late final int start;
    late final double startDur;
    late final int? end;
    late final double? endDur;

    setUp(() {
      base = DegreeProgression.fromList(
          [null, null, 'V', 'V', null, null, 'I', null]);
      sub = DegreeProgression.fromList(['ii', 'V', 'I', 'ii']);
      // Not really meant for changing, just here for formatting sake...
      start = 0;
      startDur = 0.25;
      end = 3;
      endDur = 0.25;
    });
    test('Fitting Match Locations and Possible Substitutions', () {
      // Fitting Match Locations
      List<SubstitutionMatch> matches = base.getFittingMatchLocations(
        sub,
        start: start,
        startDur: startDur,
        end: end,
        endDur: endDur,
      );
      SubstitutionMatch expectedMatch = SubstitutionMatch(
        baseIndex: start,
        baseOffset: startDur,
        subIndex: 0,
        type: SubstitutionMatchType.dry,
        ratio: 1.0,
        withSeventh: false,
      );
      expect(matches, contains(expectedMatch));

      // Possible Substitutions durations
      List<DegreeProgression> subs = base
          .getPossibleSubstitutions(
            sub,
            start: start,
            startDur: startDur,
            end: end,
            endDur: endDur,
          )
          .values
          .expand((element) => element)
          .map((e) => e.substitutedBase)
          .toList(growable: false);
      DegreeProgression expectedProgression = DegreeProgression.fromList(
        [null, 'ii', 'V', 'I', 'ii', null, 'I', null],
      );
      expect(subs, contains(expectedProgression));
    });
  });

  group('Variation Id', () {
    test('.dryVariationId', () {
      _expectVariations(
        const [
          'I, V, I',
          'vi, III, vi',
          'viidim, #IV, viidim',
        ],
        dry: true,
      );
      _expectVariations(
        const [
          'I, V, I',
          'vi, III',
          'I, V, II',
          'viidim, IV, viidim',
          'viidim, V, viidim',
        ],
        dry: true,
        fails: true,
      );
      _expectVariations(
        const [
          'I, V, I',
          'I, V, I 2',
        ],
        dry: true,
        fails: true,
      );
      _expectVariations(
        const [
          'V, I',
          'V, I 2',
        ],
        dry: true,
        fails: true,
      );
    });
    test('.variationId', () {
      _expectVariations(const [
        'I, V, I',
        'idim, Vaug, i',
      ]);
      _expectVariations(
        const [
          'I, V, I',
          'I, V, I 2',
        ],
        fails: true,
      );
      _expectVariations(
        const [
          'I, V, I',
          'vi, III, vi',
          'vi, III',
          'viidim, #IV, viidim',
        ],
        fails: true,
      );
    });
  });
}

_expectVariations(List<String> lst, {bool dry = false, fails = false}) {
  var ids = lst.map((e) {
    DegreeProgression p = DegreeProgression.parse(e);
    if (dry) {
      return p.dryVariationId;
    }
    return p.variationId();
  });
  var every = everyElement(equals(ids.first));
  if (fails) every = isNot(every);
  return expect(ids, every);
}
