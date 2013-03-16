/**
* File for painting the graph.
*/


// Parameters.
var scale = 1;
var node_count = 50 * scale;
var xmax = 18 * scale;
var ymax = 12 * scale;
var map_width_max = 900 * scale;
var map_height_max = 600 * scale;
var cell_width = Math.floor(map_width_max / xmax);
var cell_height = Math.floor(map_height_max / ymax);
var map_width = cell_width * xmax;
var map_height = cell_height * ymax;
var show_dist = false;
var run_speed = 100;


class GraphPainter {
  var _canvasElement;

  GraphPainter(this._canvasElement) {

  }

  void paint(X) {
//    context = _canvasElement.context2d();
//    context.width = map_width;
//    context.height = map_width;

  }

}


/*
var canvas = document.getElementById("map");
ctx = canvas.getContext("2d");
canvas.style.width = map_width + "px";
canvas.style.height = map_height + "px";
canvas.width = map_width;
canvas.height = map_height;
nodes = gen_nodes(node_count);
edges = gen_edges(nodes);
initialize();
redraw();                    */