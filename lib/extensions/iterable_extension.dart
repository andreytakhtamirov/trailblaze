extension IterableExtension<T> on Iterable<T> {
  Iterable<E> whereIndexed<E>(bool Function(int index, T element) test) sync* {
    var index = 0;
    for (final element in this) {
      if (test(index, element)) {
        yield element as E;
      }
      index++;
    }
  }
}
