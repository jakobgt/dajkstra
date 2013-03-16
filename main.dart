import 'dajkstra/dajkstra.dart';

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
  var gg = gen.generateGraph(10, 10, 10);
  var nodes = [new EucNode(1, 2), new EucNode(0, 2), new EucNode(1, 2)];
  nodes.sort();
  print(gen.uniq(nodes));
  print(gg);
}
