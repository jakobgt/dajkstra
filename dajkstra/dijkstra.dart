part of dajkstra;

class DijkstraAlgorithm {
  MinPriorityQueue queue;
  Map<Node, Node> destToSrc = new Map();
  Set<Node> visited = new Set();
  Map<Node, num> allCosts = new Map();
  Graph _graph;
  DijkstraAlgorithm(Graph this._graph) {
    queue =  new MinPriorityQueue(_graph.nodes);
    queue.updateCost(_graph.start, 0);
    for(Node node in _graph.nodes) {
      allCosts[node] = double.INFINITY;
    }
    allCosts[_graph.start] = 0;
  }

  Node takeStep() {
    if (queue.done()) {
      return _graph.end;
    }
    NodeAndCost next = queue.extract();
    visited.add(next.node);
    print("${next.node} and its cost: ${allCosts[next.node]}");
    if (queue.done() || allCosts[next.node] >= allCosts[_graph.end]) {
      queue.clear();
      return _graph.end;
    } else {
      PList<Edge<Node>> edges = _graph.adjacent(next.node);
      for (Edge<Node> edge in edges) {
        _updateEdge(edge);
      }
      return next.node;
    }
  }

  void _updateEdge(Edge<Node> edge) {
    var newCost = allCosts[edge.src] + edge.cost;
    if (newCost < allCosts[edge.dest]) {
      allCosts[edge.dest] = newCost;
      queue.updateCost(edge.dest, newCost);
      destToSrc[edge.dest] = edge.src;
    }
  }

  PList<Node> getPath(Node node) {
    PList<Node> path = new PList();
    path = path.cons(node);
    while(destToSrc.containsKey(node)) {
      node = destToSrc[node];
      path = path.cons(node);
    }
    return path;
  }

}

class NodeAndCost {
  Node node;
  num cost;
  NodeAndCost(this.node, this.cost);
}

class MinPriorityQueue {
  // Simple min-priority queue.
  // The complexity of Dijkstra's shortest-path algorithm depends on the
  // implementation of this priority queue. For this implementation, we
  // have a linear scan for extract which means at each step we scan up
  // to |V|, e.g., once for each node/vertice. Since we do |V| extracts,
  // the total complexity is O(V * V).  A smarter backend, e.g. binary
  // heap, for the queue can reduce this, e.g., to O(E * log V).
//  List<Node> _queue = [];
  Map<Node, num> _costs = new Map();
  MinPriorityQueue(PList<Node> nodes) {
    for(Node node in nodes) {
      _costs[node] = double.INFINITY;
    }
  }

  bool contains(Node n) => _costs.containsKey(n);

  void updateCost(Node n, num cost) {
    _costs[n] = cost;
  }

  num getCost(Node n) => _costs[n];

  NodeAndCost extract() {
    assert(!_costs.isEmpty);
    var min_n = null;
    var min_c = double.INFINITY;
    for (Node key in _costs.keys) {
      if (_costs[key] < min_c) {
        min_n = key;
        min_c = _costs[key];
      }
    }
    if (min_n == null) throw "Could not find a node with a cost.";
    _costs.remove(min_n);
    return new NodeAndCost(min_n, min_c);
  }

  bool done() => _costs.isEmpty;
  void clear() {_costs.clear();}
}
