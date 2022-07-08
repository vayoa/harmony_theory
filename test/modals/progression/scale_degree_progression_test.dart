import 'package:harmony_theory/modals/progression/scale_degree_progression.dart';
import 'package:harmony_theory/modals/substitution_match.dart';
import 'package:test/test.dart';

main() {
  group('Cut Range', () {
    late final ScaleDegreeProgression base;
    late final ScaleDegreeProgression sub;
    late final int start;
    late final double startDur;
    late final int? end;
    late final double? endDur;

    setUp(() {
      base = ScaleDegreeProgression.fromList(
          [null, null, 'V', 'V', null, null, 'I', null]);
      sub = ScaleDegreeProgression.fromList(['ii', 'V', 'I', 'ii']);
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
      List<ScaleDegreeProgression> subs = base
          .getPossibleSubstitutions(
            sub,
            start: start,
            startDur: startDur,
            end: end,
            endDur: endDur,
          )
          .map((e) => e.substitutedBase)
          .toList(growable: false);
      ScaleDegreeProgression expectedProgression =
          ScaleDegreeProgression.fromList(
        [null, 'ii', 'V', 'I', 'ii', null, 'I', null],
      );
      expect(subs, contains(expectedProgression));
    });
  });
}
