part of dajkstra;

// An euclidean node is a point on the plane with natural-number coordinates.
class EucNode implements Comparable<EucNode> {
  num _x;
  num _y;
  EucNode(this._x, this._y) {  }

  String toString() =>  "($_x, $_y)";
  bool operator ==(EucNode other) =>  _x == other._x && _y == other._y;
  bool operator <(EucNode other) => (_x < other._x) ||
                                    (_x == other._x && _y < other._y);
  num compareTo(EucNode other) => this < other ? -1 :
                                  this == other ? 0 : 1;
  num distToPoint(EucNode p) =>
      sqrt(pow(_x - p._x, 2) + pow(_y - p._y, 2));
  num distToLine(EucNode p1, EucNode p2) {
    var t = (p2._x - p1._x) * (p1._y - _y) - (p1._x - _x) * (p2._y - p1._y);
    var n = pow(p2._x - p1._x, 2) + pow(p2._y - p1._y, 2);
    return t.abs() / sqrt(n);
  }
  num get x => _x;
  num get y => _y;
}

typedef EucNode ConvertIdToEucNode(num id);
class DisplayableGraph {
  Graph graph;
  ConvertIdToEucNode euclidNodeFromId;
  DisplayableGraph(this.graph, this.euclidNodeFromId);
}

class GraphGenerator {
  Random _random = new Random();
  DisplayableGraph generateGraph(num node_count, num xmax, num ymax) {
    // nodes is a map from ids to euclidean nodes.
    List<EucNode> nodes = _generateNodes(node_count, xmax, ymax);
    List<List<num>> edges = _generateEdges(nodes);
    PList<Edge<num>> pEdges = new PList();
    for(int i = 0; i < edges.length; ++i) {
      List<num> edge = edges[i];
      for(num dst in edge) {
        if (i < dst) {
          pEdges = pEdges.cons(new Edge<num>(i, dst, nodes[i].distToPoint(nodes[dst])));
        }
      }
    }
    return new DisplayableGraph(new Graph.fromList(nodes.length, pEdges),
                                (num id) => nodes[id]);

  }

  _generateNodes(num node_count, num xmax, num ymax) {
    var nodes = new List(node_count);
    for (var i = 0; i < node_count; ++i) {
      nodes[i] = new EucNode(_random.nextInt(xmax-1), _random.nextInt(ymax-1));
    }
    nodes.sort();
    return uniq(nodes);
  }
  // Remove duplicates. Assumes that the list is sorted.
  List<EucNode> uniq(List<EucNode> nodes) {
    assert(!nodes.isEmpty);
    List<EucNode> result = [nodes[0]];
    for(int i = 1; i < nodes.length; i++) {
      EucNode node = nodes[i];
      if (result[result.length - 1] < node) {
        result.add(node);
      }
    }
    return result;
  }

  // Genereate edges in the graph.
  List<List<num>> _generateEdges(List<EucNode> nodes) {
    // Initialize edges.
    List<List<num>> edges = new List(nodes.length);
    for (var i = 0; i < nodes.length; ++i) edges[i] = [];
    // Add a few edges to each node.
    for (var src = 0; src < nodes.length; ++src) {
      for (var j = 0; j < 2; ++j) {
        var dst = _random.nextInt(nodes.length-1);
        if (identical(src, dst)) continue;
        _addEdge(src, _resolveEdge(src, dst, nodes), edges);
      }
    }
    // Add short paths while the graph remains unconnected.
    while (!_isConnected(nodes, edges))
      _connectGroup(nodes, edges);
    return edges;
  }

  // Finds the closest node to src on the line defined by the two points src and dst.
  num _resolveEdge(num src, num dst, List<EucNode> nodes) {
    var closest = nodes[src].distToPoint(nodes[dst]);
    var dst_final = dst;
    for (var i = 0; i < nodes.length; ++i) {
      if (i == dst || i == src) continue;
      var other = nodes[i];
      if (other.distToLine(nodes[src], nodes[dst]) > 1) continue;
      var dist = nodes[src].distToPoint(other);
      if (dist < closest) {
        closest = dist;
        dst_final = i;
      }
    }
    return dst_final;
  }

  // Add an undirected edge.
  // (ie, in both directions and only if the edge is not already there)
  void _addEdge(num src, num dst, List<List<num>> edges) {
    for (var i = 0; i < edges[src].length; ++i)
      if (identical(edges[src][i], dst)) return;
    edges[src].add(dst);
    edges[dst].add(src);
  }

  Set<EucNode> _getReachableNodes(List<EucNode> nodes, List<List<num>> edges) {
    // start from the root which is visited .
    var todo = [0];
    var visited = new Set<EucNode>();
    visited.add(nodes[0]);
    // for every visited node add connected non-white nodes.
    while (todo.length > 0) {
      var src = todo.removeLast();
      for (var i = 0; i < edges[src].length; ++i) {
        var dst = edges[src][i];
        if (!visited.contains(nodes[dst])) {
          visited.add(nodes[dst]);
          todo.add(dst);
        }
      }
    }

    return visited;
  }

  // Test if the graph is fully connected.
  // Colors the graph as a side effect.
  bool _isConnected(List<EucNode> nodes, List<List<num>> edges) {
    var visited = _getReachableNodes(nodes, edges);
    return visited.length == nodes.length;
  }

  // Connect some unconnected node to the closest root-connected node.
  void _connectGroup(List<EucNode> nodes, List<List<num>> edges) {
    var visited = _getReachableNodes(nodes, edges);
    for (var i = 0; i < nodes.length; ++i) {
      if (!visited.contains(nodes[i])) {
        var minIndex = -1;
        var minDist = double.INFINITY;
        for (var j = 0; j < nodes.length; ++j) {
          if (visited.contains(nodes[j])) {
            var dist = nodes[i].distToPoint(nodes[j]);
            if (minIndex == -1 || dist < minDist) {
              minIndex = j;
              minDist = dist;
            }
          }
        }
        _addEdge(i, minIndex, edges);
        return;
      }
    }
  }
}