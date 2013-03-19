part of dajkstra;

/**
 * Representation of an edge to a destination node "dest" with an
 * associated cost "cost".
 */
class Edge<T> {
  T src;
  T dest;
  num cost;
  Edge(T this.src, T this.dest, num this.cost);
  String toString() => "($src -> $dest: $cost)";
  bool operator ==(Edge<T> other) => src == other.src && dest == other.dest && cost == other.cost;
}

/**
 * Representation of a node in the graph. The identity of the node is
 * its index. Nodes should be singletons and should only be
 * constructed by the graph class.
 */
class Node {
  num _id;
  Node(num this._id);
  num get id => _id;
  String toString() => "n$_id";
  bool operator ==(Node other) => id == other.id;
}

/**
 * Abstract class for an undirected cyclic graph. Contains a list of
 * allocated nodes and defines the abstract access to edges. See
 * GraphMatrix and GraphList for two representations of the edges.
 */
abstract class Graph {
  List<Node> _nodes;
  num get nodeCount => _nodes.length;

  Graph(int node_count) {
    // Initialize nodes
    _nodes = new List(node_count);
    for (num i = 0; i < node_count; i++) {
      _nodes[i] = new Node(i);
    }
  }
  Node get start => _nodes[0];
  Node get end => _nodes[_nodes.length - 1];
  PList<Node> get nodes => new PList.fromList(_nodes);

  // Edge related interface
  void _addEdge(int i, int j, num cost);
  PList<Edge<Node>> adjacent(Node n);

  // Some predefined graphs
  factory Graph.forExercise() {
    return new GraphList(6)
        .._addEdge(0, 1, 200)
        .._addEdge(0, 2, 150)
        .._addEdge(1, 3, 150)
        .._addEdge(1, 4, 150)
        .._addEdge(2, 3, 150)
        .._addEdge(2, 4, 200)
        .._addEdge(3, 4, 50)
        .._addEdge(3, 5, 100)
        .._addEdge(4, 5, 150);
  }

  factory Graph.AU() {
    return new GraphList(7)
        .._addEdge(0, 1, 500)
        .._addEdge(0, 2, 400)
        .._addEdge(1, 3, 200)
        .._addEdge(1, 5, 400)
        .._addEdge(2, 3, 100)
        .._addEdge(2, 4, 150)
        .._addEdge(3, 4, 100)
        .._addEdge(4, 5, 150)
        .._addEdge(5, 6, 100);
  }

  factory Graph.fromList(num nodeCount, PList<Edge<num>> edges) {
    var graph = new GraphList(nodeCount);
    while(!edges.isEmpty) {
      Edge<num> edge = edges.hd;
      graph._addEdge(edge.src, edge.dest, edge.cost);
      edges = edges.tl;
    }
    return graph;
  }
}

/**
 * Representation of an undirected cyclic graph using an adjacency
 * matrix that is implicitly mirrored and with no diagonal.
 */
class GraphMatrix extends Graph {
  List<Node> _edges;
  num _offset(num i) => i * (i - 1) >> 1;

  GraphMatrix(num node_count) : super(node_count) {
    // Initialize edges with no edge (cost 0). The number of edges in
    // the list is the sum of the first node_count naturals.
    num edge_count = _offset(node_count);
    _edges = new List(edge_count);
    for (num i = 0; i < edge_count; ++i) {
      _edges[i] = 0;
    }
  }

  // Assumes i different from j. Writes the cost into the matrix.
  void _addEdge(num i, num j, num cost) {
    var minI = min(i, j);
    var maxI = max(i, j);
    _edges[_offset(maxI) + minI] = cost;
  }

  PList<Edge<Node>> adjacent(Node n) {
    PList<Edge<Node>> ns = new PList();
    num offset = _offset(n.id);
    // Find edges to previous nodes in the nodes own column
    for (num i = 0; i < n.id; ++i) {
      num cost = _edges[offset + i];
      if (cost > 0) {
        ns = ns.cons(new Edge(n, _nodes[i], cost));
      }
    }
    // Find edges to subsequent nodes in the node row of subsequent
    // columns
    for (num i = n.id + 1; i < _nodes.length; ++i) {
      num cost = _edges[_offset(i) + n.id];
      if (cost > 0) {
        ns = ns.cons(new Edge(n, _nodes[i], cost));
      }
    }
    return ns;
  }
}

/**
 * Representation of an undirected cyclic graph using an adjacency
 * list (ie, a sparse representation).
 */
class GraphList extends Graph {
  List<PList<Edge>> _edges;

  GraphList(num node_count) : super(node_count) {
    // Initialize each node with an empty list of edges.
    _edges = new List(node_count);
    for (num i = 0; i < node_count; ++i) {
      _edges[i] = new PList();
    }
  }

  // Assumes the edge is not already present. An edge is added in the
  // adjacency lists of both nodes since the graph is undirected.
  void _addEdge(num i, num j, num cost) {
    _edges[i] = _edges[i].cons(new Edge(_nodes[i], _nodes[j], cost));
    _edges[j] = _edges[j].cons(new Edge(_nodes[j], _nodes[i], cost));
  }

  PList<Edge> adjacent(Node n) => _edges[n.id];
  String toString() => "GraphList: $_nodes and $_edges";
}
