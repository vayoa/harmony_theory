import 'package:harmony_theory/modals/analysis_tools/progression_analyzer.dart';
import 'package:harmony_theory/modals/progression/degree_progression.dart';
import 'package:test/test.dart';

main() {
  group('.analyze()', () {
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
}
