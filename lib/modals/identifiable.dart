abstract class Identifiable extends Object {
  int get id;

  // TDC: I took all implementations from [SystemHash].

  static int combine(int hash, int value) {
    hash = 0x1fffffff & (hash + value);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }

  static int hash2(int v1, int v2) {
    int hash = 0;
    hash = combine(hash, v1);
    hash = combine(hash, v2);
    return finish(hash);
  }

  static int hash(Identifiable v1, Identifiable v2) {
    return hash2(v1.id, v2.id);
  }

  static int hashAll(Iterable<Identifiable> objects) {
    int hash = 0;
    for (var object in objects) {
      hash = combine(hash, object.id);
    }
    return finish(hash);
  }

  static int hashAllInts(Iterable<int> objects) {
    int hash = 0;
    for (var object in objects) {
      hash = combine(hash, object);
    }
    return finish(hash);
  }

  // TDC: Optimize...
  static int hashDouble(double n) => hashAllInts(n.toString().codeUnits);
}
