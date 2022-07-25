import 'package:harmony_theory/modals/analysis_tools/progression_analyzer.dart';
import 'package:harmony_theory/modals/progression/degree_progression.dart';
import 'package:harmony_theory/modals/theory_base/degree/degree_chord.dart';
import 'package:test/test.dart';

main() {
  group('clean functions', () {
    test('none of these functions are present', () {
      _expectCleaned('III', 'vi');
      _expectCleaned('III', 'IV');
      _expectCleaned('viidim', 'III');
      _expectCleaned('vii7', 'III');
    });

    test('remained present', () {
      _expectRemained('IV', 'V');
    });
  });

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
      _expectAnalyze(
        hard: false,
        input: 'I, III, vi, II, V,',
        expected: 'I, V/vi, vi, V/V, V',
      );
    });

    test('hard', () {
      _expectAnalyze(
          hard: true, input: 'v, I, IV', expected: 'ii/IV, V/IV, IV');
      _expectAnalyze(hard: true, input: 'I, II, V', expected: 'IV/V, V/V, V');
      _expectAnalyze(
        hard: true,
        input: 'I, III, vi, II, V,',
        expected: 'I, V/vi, ii/V, V/V, V',
      );
    });
  });

  group('.analyze() 3', () {
    test('hard', () {
      _expectAnalyze(hard: true, input: 'I, ii, VI7', expected: 'I, ii, V7/ii');
      _expectAnalyze(
        hard: true,
        input: 'vi, III, V, II, IV, III, vi',
        expected: 'vi, V/vi, V, V/V, IV, V/vi, vi',
      );
    });
  });

  group('.analyze() for slash chords', () {
    test('with a 6th as the interval...', () {
      _expectAnalyze(hard: false, input: 'vi^b6', expected: 'IVmaj7');
      _expectAnalyze(hard: false, input: 'vi^6', expected: '#iv7b5');
    });
  });
}

_expectAnalyze({
  required bool hard,
  required String input,
  required String expected,
}) =>
    expect(
      ProgressionAnalyzer.analyze(
        DegreeProgression.parse(input),
        hard: hard,
      ).toString(),
      DegreeProgression.parse(expected).toString(),
    );

int? _getMatch(String first, String second) =>
    ProgressionAnalyzer.cleanFunctions.getMatch(
      DegreeChord.parse(first),
      DegreeChord.parse(second),
    );

void _expectCleaned(String first, String second) =>
    expect(_getMatch(first, second), isNull);

void _expectRemained(String first, String second) =>
    expect(_getMatch(first, second), isNotNull);
