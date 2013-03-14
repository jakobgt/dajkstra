import "plist.dart";
import "dart:math";

class Edge {
  Node dest;
  num cost;

  Edge(this.dest, this.cost);
  String toString() => "($dest, $cost)";
}

class Node {
  num _id;
  Node(num this._id);
  num get id => this._id;
  String toString() => "n${this._id}";
}

class Graph {
  List<Node> _nodes;
  List<Node> _edges;
  num _offset(num i) => i * (i - 1) >> 1;

  Node get start => this._nodes[0];
  Node get end => this._nodes[this._nodes.length - 1];

  Graph.AU() {
    _initialize(7);
    _setEdge(0, 1, 500);
    _setEdge(0, 2, 400);
    _setEdge(1, 3, 200);
    _setEdge(1, 5, 400);
    _setEdge(2, 3, 100);
    _setEdge(2, 4, 150);
    _setEdge(3, 4, 100);
    _setEdge(4, 5, 150);
    _setEdge(5, 6, 100);
  }

  void _setEdge(num i, num j, num weight) {
    var minI = min(i, j);
    var maxI = max(i, j);
    this._edges[this._offset(maxI) + minI] = weight;
  }

  void _initialize(num node_count) {
    // Initialize nodes
    this._nodes = new List(node_count);
    for (num i = 0; i < node_count; i++) {
      this._nodes[i] = new Node(i);
    }
    // Initialize edges
    num edge_count = this._offset(node_count);
    this._edges = new List(edge_count);
    for (num i = 0; i < edge_count; ++i) {
      this._edges[i] = 0;
    }
  }

  PList<Edge> adjacent(Node n) {
    PList<Edge> ns = new PList();
    //
    num offset = this._offset(n.id);
    // Find edges to previous nodes in the nodes own column
    for (num i = 0; i < n.id; ++i) {
      num cost = this._edges[offset + i];
      if (cost > 0) {
        ns = ns.cons(new Edge(this._nodes[i], cost));
      }
    }
    // Find edges to subsequent nodes in the node row of subsequent
    // columns
    for (num i = n.id + 1; i < this._nodes.length; ++i) {
      num cost = this._edges[this._offset(i) + n.id];
      if (cost > 0) {
        ns = ns.cons(new Edge(this._nodes[i], cost));
      }
    }
    return ns;
  }
}
