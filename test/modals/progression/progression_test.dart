import 'package:harmony_theory/modals/progression/exceptions.dart';
import 'package:harmony_theory/modals/progression/progression.dart';
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
      });
    });
  });
}

_errorlessEqual<T>(Progression<T> p1, Progression<T> p2) {
  // Check that splitToMeasures doesn't throw an error.
  expect(() => p1.toString(), returnsNormally);
  expect(() => p2.toString(), returnsNormally);
  return expect(p1, equals(p2));
}
