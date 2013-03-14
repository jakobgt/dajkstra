import "graph.dart";
import "naive.dart";
import "plist.dart";

void main() {
  Graph g = new Graph.AU();
  PList<Edge> adjacent = g.adjacent(g.start);
  print(adjacent);
  print(g.adjacent(g.end));
  print(new NaiveAlgorithm().findShortestPath(g));
}
