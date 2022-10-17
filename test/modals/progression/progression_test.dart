import 'package:harmony_theory/modals/progression/exceptions.dart';
import 'package:harmony_theory/modals/progression/progression.dart';
import 'package:harmony_theory/modals/progression/time_signature.dart';
import 'package:test/test.dart';

main() {
  group('Constructors', () {
    group('.parse', () {
      parser(input) => int.parse(input);

      test('invalid', () {
        expect(
          () => Progression<int>.parse(
              input: '1 3, 2 2, 3 2, 4, 5 2', parser: parser),
          throwsA(isA<NonValidDuration>()),
        );
        expect(
          () => Progression<int>.parse(
              input: '1, 2 2, 3 4, 4, 5 2', parser: parser),
          throwsA(isA<NonValidDuration>()),
        );
      });
      test('valid', () {
        expect(
          () => Progression<int>.parse(
              input: '1 1, 2 -1, 3, 4, 5 2, ,', parser: parser),
          returnsNormally,
        );
        _errorlessEqual(
          Progression<int>.parse(input: '1, 2 2, 3 3, 4, 5 2', parser: parser),
          Progression<int>(
            [1, 2, 3, 4, 5],
            [0.25, 0.5, 0.75, 0.25, 0.5],
          ),
        );
        _errorlessEqual(
          Progression<int>.parse(
              input: '1 4, 3 2, 3, 3, 7 2, 5 2, 1 4', parser: parser),
          Progression<int>(
            [1, 3, 7, 5, 1],
            [1.0, 1.0, 0.5, 0.5, 1.0],
          ),
        );
        _errorlessEqual(
          Progression<int>.parse(input: '1, 2 2, 3 3, 4, 5 2', parser: parser),
          Progression<int>(
            [1, 2, 3, 4, 5],
            [0.25, 0.5, 0.75, 0.25, 0.5],
          ),
        );
        _errorlessEqual(
          Progression<int>.parse(input: '1 2, 2 2, 3, 4, 5 2', parser: parser),
          Progression<int>(
            [1, 2, 3, 4, 5],
            [0.5, 0.5, 0.25, 0.25, 0.5],
          ),
        );
        _errorlessEqual(
          Progression<int>.parse(input: '1 2, 2 2, 3, 4 2, 5,', parser: parser),
          Progression<int>(
            [1, 2, 3, 4, 5],
            [0.5, 0.5, 0.25, 0.5, 0.25],
          ),
        );
        _errorlessEqual(
          _parse('A 2, B M, M'),
          Progression<String>(
            ['A', 'B', null],
            [0.5, 1.0, 1.0],
          ),
        );
        _errorlessEqual(
          _parse('A h, B M, M'),
          Progression<String>(
            ['A', 'B', null],
            [0.5, 1.0, 1.0],
          ),
        );
        _errorlessEqual(
          Progression<String>(
            ['A', 'B', null],
            [0.5, 0.75, 0.75],
            timeSignature: const TimeSignature(3, 4),
          ),
          _parse('A 2, B M, M', false),
        );
      });
    });
  });
  group('methods', () {
    test('.deleteRange', () {
      var p = _parse('A 4, B 4');
      _errorlessEqual(p.deleteRange(0.5, 1.5), _parse('A 2, B 2'));
      p = _parse('A 2, B 2, C 4');
      _errorlessEqual(p.deleteRange(0.5, 1.5), _parse('A 2, C 2'));
      p = _parse('A 2, B 2, C 4');
      _errorlessEqual(p.deleteRange(0.75, 1.5), _parse('A 2, B, C 2'));
      p = _parse('A 2, B 2, C 2');
      _errorlessEqual(p.deleteRange(0.75, 1.25), _parse('A 2, B, C '));
      p = _parse('E 4, A 2, B 2, C 2, E 2');
      _errorlessEqual(
          p.deleteRange(1.75, 2.25), _parse('E 4, A 2, B, C, E 2 '));
      p = _parse(
          'vi 2, II 2, vii° 2, III, III7, VI7 2, II 2, V 2, III, III7, vi 4');
      _errorlessEqual(p.deleteRange(0, 1.5),
          _parse('III, III7, VI7 2, II 2, V 2, III, III7, vi 4'));
      p = _parse('// 20');
      _errorlessEqual(p.deleteRange(3, 5), _parse('// 12'));
      _errorlessEqual(p.deleteRange(3, 4.5), _parse('// 14'));
    });
  });
}

Progression<String> _parse(String input, [bool fourByFour = true]) =>
    Progression<String>.parse(
      input: input,
      parser: (input) => input,
      timeSignature: fourByFour
          ? const TimeSignature.evenTime()
          : const TimeSignature(3, 4),
    );

_errorlessEqual<T>(Progression<T> p1, Progression<T> p2) {
  // Check that splitToMeasures doesn't throw an error.
  expect(() => p1.toString(), returnsNormally);
  expect(() => p2.toString(), returnsNormally);
  return expect(p1, equals(p2));
}
