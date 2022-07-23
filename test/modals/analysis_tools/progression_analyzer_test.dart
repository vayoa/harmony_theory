import 'package:harmony_theory/modals/analysis_tools/progression_analyzer.dart';
import 'package:harmony_theory/modals/progression/degree_progression.dart';
import 'package:test/test.dart';

main() {
  group('.analyze() 1', () {
    late DegreeProgression progression;
    late DegreeProgression progression2;
    late DegreeProgression progressionNull;
    late DegreeProgression progressionNull2;

    setUp(() {
      progression = DegreeProgression.fromList([
        'I',
        'I',
        'viidim',
        'III',
        'vi',
        'vi',
      ]);
      progression2 = DegreeProgression.fromList([
        'I',
        'I',
        'vi',
        'vi',
        'viidim',
        'III',
        'vi',
        'vi',
      ]);
      progressionNull = DegreeProgression.fromList([
        'I',
        'I',
        'viidim',
        null,
        'vi',
        'vi',
      ]);
      progressionNull2 = DegreeProgression.fromList([
        'I',
        'I',
        'vi',
        'vi',
        'viidim',
        null,
        'vi',
        'vi',
      ]);
    });

    group('regular', () {
      test('no nulls', () {
        expect(
          ProgressionAnalyzer.analyze(progression, hard: false).toString(),
          equals(DegreeProgression.fromList([
            'I',
            'I',
            'viidim',
            'V/vi',
            'vi',
            'vi',
          ]).toString()),
        );
        expect(
          ProgressionAnalyzer.analyze(progression2, hard: false).toString(),
          equals(DegreeProgression.fromList([
            'I',
            'I',
            'vi',
            'vi',
            'viidim',
            'V/vi',
            'vi',
            'vi',
          ]).toString()),
        );
      });
      test('with nulls', () {
        expect(
          ProgressionAnalyzer.analyze(progressionNull, hard: false).toString(),
          equals(DegreeProgression.fromList([
            'I',
            'I',
            'viidim',
            null,
            'vi',
            'vi',
          ]).toString()),
        );
        expect(
          ProgressionAnalyzer.analyze(progressionNull2, hard: false).toString(),
          equals(DegreeProgression.fromList([
            'I',
            'I',
            'vi',
            'vi',
            'viidim',
            null,
            'vi',
            'vi',
          ]).toString()),
        );
      });
    });

    group('hard', () {
      test('no nulls', () {
        expect(
          ProgressionAnalyzer.analyze(progression, hard: true).toString(),
          equals(DegreeProgression.fromList([
            'I',
            'I',
            'iidim/vi',
            'V/vi',
            'vi',
            'vi',
          ]).toString()),
        );
        expect(
          ProgressionAnalyzer.analyze(progression2, hard: true).toString(),
          equals(DegreeProgression.fromList([
            'I',
            'I',
            'vi',
            'vi',
            'iidim/vi',
            'V/vi',
            'vi',
            'vi',
          ]).toString()),
        );
      });
      test('with nulls', () {
        expect(
          ProgressionAnalyzer.analyze(progressionNull, hard: true).toString(),
          equals(DegreeProgression.fromList([
            'I',
            'I',
            'viidim',
            null,
            'vi',
            'vi',
          ]).toString()),
        );
        expect(
          ProgressionAnalyzer.analyze(progressionNull2, hard: true).toString(),
          equals(DegreeProgression.fromList([
            'I',
            'I',
            'vi',
            'vi',
            'viidim',
            null,
            'vi',
            'vi',
          ]).toString()),
        );
      });
    });
  });
  group('.analyze() 2', () {
    test('normal', () {
      expect(
        ProgressionAnalyzer.analyze(
                DegreeProgression.parse('I, III, vi, II, V,'),
                hard: false)
            .toString(),
        DegreeProgression.parse('I, V/vi, vi, V/V, V').toString(),
      );
    });

    test('hard', () {
      expect(
        ProgressionAnalyzer.analyze(DegreeProgression.parse('v, I, IV'),
                hard: true)
            .toString(),
        DegreeProgression.parse('ii/IV, V/IV, IV').toString(),
      );

      expect(
        ProgressionAnalyzer.analyze(DegreeProgression.parse('I, II, V'),
                hard: true)
            .toString(),
        DegreeProgression.parse('IV/V, V/V, V').toString(),
      );

      expect(
        ProgressionAnalyzer.analyze(
                DegreeProgression.parse('I, III, vi, II, V,'),
                hard: true)
            .toString(),
        DegreeProgression.parse('I, V/vi, ii/V, V/V, V').toString(),
      );
    });
  });
  group('.analyze() for slash chords', () {
    test('with a 6th as the interval...', () {
      expect(
        ProgressionAnalyzer.analyze(DegreeProgression.parse('vi^b6'))
            .toString(),
        DegreeProgression.parse('IVmaj7').toString(),
      );
      expect(
        ProgressionAnalyzer.analyze(DegreeProgression.parse('vi^6')).toString(),
        DegreeProgression.parse('#iv7b5').toString(),
      );
    });
  });
}
