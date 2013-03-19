import 'dajkstra/dajkstra.dart';

/*
 Main file for running the algorithms from the command line.
 */

void main() {
  Graph g = new Graph.forExercise();
  PList<Edge> adjacent = g.adjacent(g.start);
  print(adjacent);
  print(g.adjacent(g.end));
  var pathCount = 0;
  print(new NaiveAlgorithm().findShortestPath(g, onPath : (p) {
    pathCount++;
    print(p);
  }));
  print("path count: $pathCount");
  var dijkstraAlgorithm = new DijkstraAlgorithm(g);
  Node nextStep;
  while((nextStep = dijkstraAlgorithm.takeStep()) != g.end) {
    print(nextStep);
  }
}
