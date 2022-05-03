import 'package:thoery_test/modals/identifiable.dart';

class AbsoluteDurations implements Identifiable {
  late final List<double> _real;

  AbsoluteDurations(this._real);

  AbsoluteDurations.fromDurations(List<double> durations) {
    _real = [];
    double sum = 0.0;
    for (double duration in durations) {
      sum += duration;
      _real.add(sum);
    }
  }

  AbsoluteDurations.empty() : this([]);

  AbsoluteDurations get copy => AbsoluteDurations([..._real]);

  AbsoluteDurations sublist(int start, [int? end]) {
    assert(start >= 0 &&
        start < length &&
        (end == null || (end <= length && start <= end)));
    end ??= length;
    List<double> nextReal = [];
    double prev = 0.0;
    if (start > 1) prev = _real[start - 1];
    for (int i = start; i < end; i++) {
      nextReal.add(_real[i] - prev);
    }
    return AbsoluteDurations(nextReal);
  }

  bool get isEmpty => _real.isEmpty;

  bool get isNotEmpty => _real.isNotEmpty;

  int get length => _real.length;

  double operator [](int index) {
    assert(index >= 0 && index < length);
    if (index == 0) return _real[0];
    return _real[index] - _real[index - 1];
  }

  void operator []=(int index, double duration) {
    double diff = duration - this[index];
    for (int i = index; i < length; i++) {
      _real[i] += diff;
    }
  }

  double get first => this[0];

  double get last => this[length - 1];

  set last(double duration) {
    assert(length > 0);
    if (length == 1) {
      _real[0] = duration;
    } else {
      _real[length - 1] = _real[length - 2] + duration;
    }
  }

  double get realLast => _real[length - 1];

  List<double> get realDurations => _real;

  double real(int index) => _real[index];

  void setReal(int index, double duration) => _real[index] = duration;

  void add(double duration) {
    double prev = 0.0;
    if (length > 0) prev = _real[length - 1];
    _real.add(duration + prev);
  }

  void addAll(AbsoluteDurations other, {int from = 0}) {
    for (int i = from; i < other.length; i++) {
      _real.add(_real.last + other[i]);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is AbsoluteDurations &&
      other.length == length &&
      other._real == _real;

  /// Hashes based on rhythm relations. We take the first duration and base
  /// the whole other ones on the relation between them and it.
  @override
  int get hashCode {
    if (_real.isEmpty) return Object.hashAll(_real);
    double _first = _real.first;
    List<double> relations = [for (double dur in _real) dur / _first];
    return Object.hashAll(relations);
  }

  @override
  int get id {
    int hash = 0;
    if (_real.isEmpty) return hash;
    double _first = _real.first;
    for (double dur in _real) {
      hash = Identifiable.combine(hash, (dur / _first).hashCode);
    }
    return Identifiable.finish(hash);
  }

  @override
  String toString() {
    String output = '[';
    for (int i = 0; i < length - 1; i++) {
      output += '${this[i]}, ';
    }
    if (isNotEmpty) output += last.toString();
    return output + ']';
  }
}
