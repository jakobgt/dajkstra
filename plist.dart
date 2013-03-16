part of dajkstra;

/**
 * Persistent/immutable singly linked list. The base case, ie, the
 * empty list is defined by PList and PCons implements a link in a
 * non-empty list.
 */
class PList<T> {
  PList();
  bool get empty => true;
  PList<T> cons(T hd) => new PCons(hd, this);

  int get length {
    int len = 0;
    PList<T> curr = this;
    while (!curr.empty) {
      ++len;
      curr = curr.tl;
    }
    return len;
  }

  bool any(pred) {
    PList<T> curr = this;
    while (!curr.empty) {
      if (pred(curr.hd)) return true;
      curr = curr.tl;
    }
    return false;
  }

  String toString() {
    var str = new StringBuffer("[");
    if (!this.empty) {
      str.write(this.hd.toString());
      PList<T> ls = this.tl;
      while (ls is PCons) {
        str.write(", ");
        str.write(ls.hd.toString());
        ls = ls.tl;
      }
    }
    str.write("]");
    return str.toString();
  }
}

/**
 * An immutable cons cell in a linked list.
 */
class PCons<T> extends PList<T> {
  T _hd;
  PList<T> _tl;
  PCons(T this._hd, PList<T> this._tl);
  T get hd => this._hd;
  PList<T> get tl => this._tl;
  bool get empty => false;
}
