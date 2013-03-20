part of dajkstra;

const INVALID = double.INFINITY;
var graph = null;

findShortestPath(in_graph) {
  graph = in_graph;
  return search(graph.start, new PList(), 0);
}

search(currentNode, currentPath, currentCost) {
  // NodeState:
  // Considering a new node in our search. Here 'currentNode' is the
  // node we are currently considering, 'currentPath' is the path of
  // nodes we have taken up to this point (not including
  // 'currentNode') and 'currentCost' is the total cost of the path up
  // to the current node. The graph is represented by 'graph'.

  if (currentNode == graph.end) {
    // PathState:
    // A path has been found since 'currentNode' is the end point of
    // the path. So the result is the cost of this path.
    return currentCost;
  }

  for (var visitedNode in currentPath) {
    if (visitedNode == currentNode) {
      // CycleState:
      // A cycle has been found since 'currentNode' has already been
      // visited.  I.e., it is already in the 'currentPath' list.  So
      // the result is "invalid" signified by the infinitely large cost.
      return INVALID;
    }
  }

  // Starting with an "invalid" cost, i.e., we don't know if there
  // exists a path yet, we consider each edge of 'currentNode' in turn:
  var lowestCost = INVALID;
  for (var edge in graph.adjacent(currentNode)) {

    // Ignore the edge if it points back to the last visited node,
    // i.e., where we just came from.
    if (!currentPath.isEmpty && edge.dest == currentPath.hd) {
      continue;
    }

    // EdgesState:
    // Considering an edge, 'edge', in the search for the best path.
    var cost = search(edge.dest,                      // The edge destination
                      currentPath.cons(currentNode),  // The new currentPath
                      currentCost + edge.cost);       // The new currentCost

    // ContState:
    // A new path has been found. If it is better than our current
    // best path 'bestResult', then replace 'bestResult' with the new
    // path.
    if (cost < lowestCost) {
        lowestCost = cost;
    }
  }

  // Return the best cost we have found.
  return lowestCost;
}
