part of dajkstra;

class Result {
  PList<Node> path;
  num cost;
  Result(PList<Node> this.path, num this.cost);
  Result.NoPath() {
    path = new PList();
    cost = double.INFINITY;
  }
  bool get valid => cost < double.INFINITY;
  String toString() => "Cost: $cost, path: $path";
}

class NaiveAlgorithm {
  var _onPath, _onCycle;
  Result findShortestPath(Graph graph, {onPath: null, onCycle: null}) {
    _onPath = (onPath != null) ? onPath : (_) {};
    _onCycle = (onCycle != null) ? onCycle : (_) {};
    return _findFromCurrentNode(graph.start, new PList(), 0, graph);
  }

  Result _findFromCurrentNode(Node currentNode,
                              PList<Node> currentPath,
                              num currentCost,
                              Graph graph) {
    var currentFullPath = currentPath.cons(currentNode);
    if (currentNode.id == graph.end.id) {
      _onPath(currentFullPath);
      return new Result(currentFullPath, currentCost);
    }
    if (currentPath.any((elm) => elm.id == currentNode.id)) {
      _onCycle(currentFullPath);
      return new Result.NoPath();
    }
    visit(PList<Edge> edges, Result bestRes) {
      if (edges.isEmpty) {
        return bestRes;
      } else if (!currentPath.isEmpty && edges.hd.dest == currentPath.hd) {
        return visit(edges.tl, bestRes);
      } else {
        var edge = edges.hd;
        var result = _findFromCurrentNode(edge.dest, currentFullPath,
                                          currentCost + edge.cost, graph);
        return visit(edges.tl, (result.cost < bestRes.cost) ? result : bestRes);
      }
    }
    return visit(graph.adjacent(currentNode), new Result.NoPath());
  }
}

