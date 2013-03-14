class PList<T> {
  PList();
  bool get empty => true;
  String toString() => "[]";
  PList<T> cons(T hd) => new PCons(hd, this);
}

class PCons<T> extends PList<T> {
  T _hd; PList<T> _tl;
  PCons(T this._hd, PList<T> this._tl);

  T get hd => this._hd;
  PList<T> get tl => this._tl;
  bool get empty => false;

  String toString() {
    var str = new StringBuffer("[");
    str.write(this.hd.toString());
    PList<T> ls = this.tl;
    while (ls is PCons) {
      str.write(", ");
      str.write(ls.hd.toString());
      ls = ls.tl;
    }
    str.write("]");
    return str.toString();
  }
}
