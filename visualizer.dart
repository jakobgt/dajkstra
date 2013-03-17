/**
*  This file is used to run the algorithms in the browser.
*/

import 'dart:html' show query;
import 'dajkstra/dajkstra.dart';
import 'graph-painter.dart';

var scale = 1;
var node_count = 50 * scale;
var xmax = 18 * scale;
var ymax = 12 * scale;
var mapWidthMax = 900 * scale;
var mapHeightMax = 600 * scale;

void main() {
  print("Running main");
  GraphGenerator graphGenerator = new GraphGenerator();
  DisplayableGraph graph = graphGenerator.generateGraph(node_count, xmax, ymax);
  GraphPainter graphPainter =
      new GraphPainter(query("#map"), xmax, ymax, mapWidthMax, mapHeightMax);
  graphPainter.drawGraph(graph);
}