part of dajkstra;

// An euclidian node is a point on the plane with natural-number coordinates.
class EucNode implements Comparable<EucNode> {
  num _id = -1; // Will be set after sorting.
  num _x;
  num _y;
  EucNode(this._x, this._y) {  }

  String toString() =>  "($_x,$_y)";
  bool isEqual(EucNode other) =>  _x == other._x && _y == other._y;
  bool isLessThan(EucNode other) => (_x < other._x) ||
                                    (_x == other._x && _y < other._y);
  num compareTo(EucNode other) => this.isLessThan(other) ? -1 :
                                  this.isEqual(other) ? 0 : 1;
  num distToPoint(EucNode p) =>
      Math.sqrt(dist_sq = Math.pow(_x - p._x, 2) + Math.pow(_y - p._y, 2));
  num distToLine(EucNode p1, EucNode p2) {
    var t = (p2._x - p1._x) * (p1._y - _y) - (p1._x - _x) * (p2._y - p1._y);
    var n = Math.pow(p2._x - p1._x, 2) + Math.pow(p2._y - p1._y, 2);
    return Math.abs(t) / Math.sqrt(n);
  }
}

class GraphGenerator {
  generateGraph(node_count, xmax, ymax) {
    List<EucNode> nodes = _generateNodes(node_count, xmax, ymax);
  }

  _generateNodes(node_count, xmax, ymax) {
    var nodes = [];
    for (var i = 0; i < node_count; ++i) {
      nodes[i] = new EucNode(random(0, xmax-1), random(0, ymax-1));
    }
    nodes.sort();
    return uniq(nodes);
  }

  List<EucNode> uniq(List<EucNode> nodes) {
    assert(!nodes.isEmpty());
    List<EucNode> result = [];
    int j = 0;
    for(int i = 1; i < nodes.length; i++) {
      if (result[result.length - 1].isLessThan(node)) {
        result.add(node);
      }
    }
    return result;
  }




}

