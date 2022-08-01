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
        expect(
          Progression<int>.parse(input: '1, 2 2, 3 3, 4, 5 2', parser: parser),
          equals(
            Progression<int>(
              [1, 2, 3, 4, 5],
              [0.25, 0.5, 0.75, 0.25, 0.5],
            ),
          ),
        );
        expect(
          Progression<int>.parse(input: '1, 2 2, 3 3, 4, 5 2', parser: parser),
          equals(
            Progression<int>(
              [1, 2, 3, 4, 5],
              [0.25, 0.5, 0.75, 0.25, 0.5],
            ),
          ),
        );
        expect(
          Progression<int>.parse(input: '1 2, 2 2, 3, 4, 5 2', parser: parser),
          equals(
            Progression<int>(
              [1, 2, 3, 4, 5],
              [0.5, 0.5, 0.25, 0.25, 0.5],
            ),
          ),
        );
        expect(
          Progression<int>.parse(input: '1 2, 2 2, 3, 4 2, 5,', parser: parser),
          equals(
            Progression<int>(
              [1, 2, 3, 4, 5],
              [0.5, 0.5, 0.25, 0.5, 0.25],
            ),
          ),
        );
      });
    });
  });
}
