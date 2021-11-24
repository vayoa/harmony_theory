import 'package:tonic/tonic.dart';

extension ChordExtension on Chord {
  String getCommonName() {
    return root.pitchClass.toString() + pattern.abbr;
  }
}