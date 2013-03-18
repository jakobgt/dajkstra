part of dajkstra;

/**
 * Persistent/immutable singly linked list. The base case, ie, the
 * empty list is defined by PList and PCons implements a link in a
 * non-empty list.
 */
class PList<T> extends Iterable<T> {
  // Create an empty persistent list.
  PList();

  // Create a persistent list with elements taken from another list.
  factory PList.fromList(List<T> list) {
    PList<T> pList = new PList();
    for(int i = list.length -1; i >= 0; --i) {
      pList = pList.cons(list[i]);
    }
    return pList;
  }

  // Add an element to the front of the list.
  PList<T> cons(T hd) => new PCons(hd, this);

  // Get an iterator object for this list.
  Iterator<T> get iterator => new PListIterator<T>(this);

  // Pretty print the list
  String toString() => "[${join(', ')}]";

  // Some utility functions not defined by Iterable.
  dynamic foldr(dynamic fn(T, dynamic), dynamic acc) => acc;
  PList<T> reverse() => reduce(new PList(), (ys, x) => ys.cons(x));
}

/**
 * An immutable cons cell in a linked list.
 */
class PCons<T> extends PList<T> {
  final T hd;        // The head or the first element of the list.
  final PList<T> tl; // The tail or the "rest" of the list.

  // Internally construct a cell in the list. See PList.cons.
  PCons(T this.hd, PList<T> this.tl);

  // Inductive case of the recursive fold. Use Iterable.reduce for a "foldl".
  dynamic foldr(dynamic fn(T, dynamic), dynamic acc)
      => fn (hd, tl.foldr(fn, acc));
}

/**
 * A (non-persistent) iterator for a persistent list. Uses a dummy
 * cons cell since the first element in the sequence is the content of
 * 'current' after a call to 'moveNext'.
 */
class PListIterator<T> implements Iterator<T> {
  PList<T> curr;
  PListIterator(xs) : this.curr = xs.cons(null);
  T get current => curr.hd;
  bool moveNext() {
    if (curr.tl is PCons) {
      curr = curr.tl;
      return true;
    }
    return false;
  }
}
