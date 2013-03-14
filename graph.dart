import "plist.dart";

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

  Graph(num node_count) {
    // Initialize nodes
    this._nodes = new List(node_count);
    for (num i = 0; i < node_count; i++) {
      this._nodes[i] = new Node(i);
    }
    // Initialize edges
    num edge_count = this._offset(node_count);
    this._edges = new List(edge_count);
    for (num i = 0; i < edge_count; ++i) {
      this._edges[i] = 1;
    }
  }

  PList<Node> adjacent(Node n) {
    PList<Node> ns = new PList();
    //
    num offset = this._offset(n.id);
    // Find edges to previous nodes in the nodes own column
    for (num i = 0; i < n.id; ++i) {
      num edge = this._edges[offset + i];
      if (edge > 0) {
        ns = ns.cons(this._nodes[i]);
      }
    }
    // Find edges to subsequent nodes in the node row of subsequent
    // columns
    for (num i = n.id + 1; i < this._nodes.length; ++i) {
      num edge = this._edges[this._offset(i) + n.id];
      if (edge > 0) {
        ns = ns.cons(this._nodes[i]);
      }
    }
    return ns;
  }
}
