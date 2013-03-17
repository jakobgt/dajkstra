/**
* File for painting the graph.
*/
library graph_gui;
import "dart:html" hide Node;
import "dart:math";
import 'dajkstra/dajkstra.dart';

class GraphPainter {
  CanvasElement _canvasElement;
  num _xmax;
  num _ymax;
  num _mapWidth;
  num _mapHeight;
  num _cellWidth;
  num _cellHeight;

  GraphPainter(this._canvasElement,
               this._xmax,
               this._ymax,
               num mapWidthMax,
               num mapHeightMax) {
    _cellWidth = (mapWidthMax / _xmax).floor();
    _cellHeight = (mapHeightMax / _ymax).floor();
    _mapWidth = _cellWidth * _xmax;
    _mapHeight = _cellHeight * _ymax;
    _canvasElement.width = _mapWidth;
    _canvasElement.height = _mapHeight;
  }

  void drawGraph(DisplayableGraph graph) {
    var context = _canvasElement.context2d;
    context.clearRect(0, 0, _mapWidth, _mapHeight);
    _drawGrid(context);
    _drawEdges(context, graph);
    _drawNodes(context, graph);
  }

  void _drawGrid(CanvasRenderingContext2D context) {
    context.beginPath();
    context.strokeStyle = "#eee";
    for (int i = _cellWidth/2; i < _mapWidth; i += _cellWidth) {
      context.moveTo(i, 0);
      context.lineTo(i, _mapHeight);
    }
    for (int i = _cellHeight/2; i < _mapHeight; i += _cellHeight) {
      context.moveTo(0, i);
      context.lineTo(_mapWidth, i);
    }
    context.stroke();
  }

  num _scaleX(num x) => x * _cellWidth + _cellWidth/2;
  num _scaleY(num y) => y * _cellHeight + _cellHeight/2;

  void _drawNodes(CanvasRenderingContext2D ctx, DisplayableGraph graph) {
    PList<Node> nodes = graph.graph.nodes;
    while(!nodes.empty) {
      Node node = nodes.hd;
      EucNode eucNode = graph.euclidNodeFromId(node.id);
      ctx.beginPath();
      var sx = _scaleX(eucNode.x);
      var sy = _scaleY(eucNode.y);
      ctx.arc(sx, sy, 17, 0, PI*2, true);
      ctx.closePath();
      ctx.strokeStyle = "gray";
      ctx.lineWidth = 2;
      ctx.fillStyle
      = (node.id == 0) ? "lightgreen"
      : (node.id == graph.graph.nodeCount - 1) ? "#F17022"
      : "gray";
      ctx.fill();
      ctx.stroke();
      nodes = nodes.tl;
    }
  }

  void _drawEdges(CanvasRenderingContext2D ctx, DisplayableGraph graph) {
    graph.graph.nodes.map((Node srcNode) {
      EucNode eucNode = graph.euclidNodeFromId(srcNode.id);
      var eucNodeSX = _scaleX(eucNode.x);
      var eucNodeSY = _scaleY(eucNode.y);
      PList<Edge<Node>> edges = graph.graph.adjacent(srcNode);
      edges.map((Edge<Node> edge) {
        var dstNode = edge.dest;
        ctx.beginPath();
        ctx.strokeStyle = "gray";
        ctx.lineWidth = 2;
        EucNode dstEucNode = graph.euclidNodeFromId(dstNode.id);
        var dstNodeSX = _scaleX(dstEucNode.x);
        var dstNodeSY = _scaleY(dstEucNode.y);
        ctx.moveTo(eucNodeSX, eucNodeSY);
        ctx.lineTo(dstNodeSX, dstNodeSY);
        ctx.stroke();
      });
    });
  }

}
