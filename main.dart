import 'package:dajkstra/dajkstra.dart';

/*
 Main file for running the algorithms from the command line.
 */

void main() {
  Graph g = new Graph.AU();
  PList<Edge> adjacent = g.adjacent(g.start);
  print(adjacent);
  print(g.adjacent(g.end));
  var pathCount = 0;
  print(new NaiveAlgorithm().findShortestPath(g/*, onPath : (p) => pathCount++*/));
  print("path count: $pathCount");

  GraphGenerator gen = new GraphGenerator();
}
