/**
* Class for painting a graph to a HTML canvas.
*/

library graph_gui;

import "dart:html" hide Node;

import "dart:math";

import 'dajkstra/dajkstra.dart';

class GraphPainter {
  CanvasElement _canvasElement;

  CanvasRenderingContext2D _context;

  num _xmax;

  num _ymax;

  num _mapWidth;

  num _mapHeight;

  num _cellWidth;

  num _cellHeight;

  GraphPainter(this._canvasElement, this._xmax, this._ymax, num mapWidthMax, num mapHeightMax) {
    _cellWidth = (mapWidthMax / _xmax).floor();
    _cellHeight = (mapHeightMax / _ymax).floor();
    _mapWidth = _cellWidth * _xmax;
    _mapHeight = _cellHeight * _ymax;
    _canvasElement.width = _mapWidth;
    _canvasElement.height = _mapHeight;
    _context = _canvasElement.context2d;
  }

  void _initCanvas() {
    context.clearRect(0, 0, _mapWidth, _mapHeight);
    _drawGrid(context);
  }

  void drawGraph(DisplayableGraph graph) {
    _initCanvas();
    _drawEdges(context, graph);
    _drawNodes(context, graph);
  }

  void drawPath(DisplayableGraph graph, PList<Node> path) {
    _initCanvas();
    _drawEdges(context, graph);
    _drawPath(context, graph, path);
// Nodes that are in the path are colored white. All other gray (except start and end)_drawNodes(context, graph, colorFun: (Node n) => (path.any((Node other) => n.id == other.id)) ? "white" : "gray");
  }

  void _drawPath(CanvasRenderingContext2D context, DisplayableGraph graph, PList<Node> path) {
    if (path.empty) return;
    context.beginPath();
    context.strokeStyle = "lightgreen";
    context.lineWidth = 5;
    path.foldr((node, acc) {
      var eucNode = graph.euclidNodeFromId(node.id);
      if (acc) {
        context.moveTo(_transformX(eucNode.x), _transformY(eucNode.y));
      } else {
        context.lineTo(_transformX(eucNode.x), _transformY(eucNode.y));
      }
      return false;
    }, true);
// Acc states whether it is the firstcontext.stroke();
  }

  void _drawGrid(CanvasRenderingContext2D context) {
    context.beginPath();
    context.strokeStyle = "#eee";
    for (int i = _cellWidth / 2; i < _mapWidth; i += _cellWidth) {
      context.moveTo(i, 0);
      context.lineTo(i, _mapHeight);
    }
    for (int i = _cellHeight / 2; i < _mapHeight; i += _cellHeight) {
      context.moveTo(0, i);
      context.lineTo(_mapWidth, i);
    }
    context.stroke();
  }

  num _transformX(num x) => x * _cellWidth + _cellWidth / 2;

  num _transformY(num y) => y * _cellHeight + _cellHeight / 2;

  void _drawNodes(CanvasRenderingContext2D ctx, DisplayableGraph graph, {
  colorFun: null
  }) {
    colorFun = (colorFun == null) ? (_) => "gray" : colorFun;
    PList<Node> nodes = graph.graph.nodes;
    while (!nodes.empty) {
      Node node = nodes.hd;
      EucNode eucNode = graph.euclidNodeFromId(node.id);
      ctx.beginPath();
      var sx = _transformX(eucNode.x);
      var sy = _transformY(eucNode.y);
      ctx.arc(sx, sy, 17, 0, PI * 2, true);
      ctx.closePath();
      ctx.strokeStyle = "gray";
      ctx.lineWidth = 2;
      ctx.fillStyle = (node.id == 0) ? "lightgreen" // Start node : (node.id == graph.graph.nodeCount - 1) ? "#F17022" //end node : colorFun(node);ctx.fill();ctx.stroke();
      nodes = nodes.tl;
    }
  }

  void _drawEdges(CanvasRenderingContext2D ctx, DisplayableGraph graph) {
    graph.graph.nodes.map((Node srcNode) {
      EucNode eucNode = graph.euclidNodeFromId(srcNode.id);
      var eucNodeSX = _transformX(eucNode.x);
      var eucNodeSY = _transformY(eucNode.y);
      PList<Edge<Node>> edges = graph.graph.adjacent(srcNode);
      edges.map((Edge<Node> edge) {
        var dstNode = edge.dest;
        ctx.beginPath();
        ctx.strokeStyle = "gray";
        ctx.lineWidth = 2;
        EucNode dstEucNode = graph.euclidNodeFromId(dstNode.id);
        var dstNodeSX = _transformX(dstEucNode.x);
        var dstNodeSY = _transformY(dstEucNode.y);
        ctx.moveTo(eucNodeSX, eucNodeSY);
        ctx.lineTo(dstNodeSX, dstNodeSY);
        ctx.stroke();
      });
    });
  }

}
