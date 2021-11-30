import 'package:tonic/tonic.dart';

extension ScaleExtension on Scale {
  String getCommonName() {
    final String scaleTonic = tonic.toString();
    final String scalePattern =
    pattern.name == 'Diatonic Major' ? 'Major' : 'Minor';
    return scaleTonic + ' ' + scalePattern;
  }
}