/**
* Class for painting a graph to a HTML canvas.
*/
library graph_gui;
import "dart:html" hide Node;
import "dart:math";
import 'dajkstra/dajkstra.dart';

typedef String EdgeColorFunc(Node, Node);
typedef String NodeColorFunc(Node);
typedef String NodeTextFunc(Node);

class GraphPainter {
  CanvasElement _canvasElement;
  CanvasRenderingContext2D _context;
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
    _context = _canvasElement.context2d;
  }

  void _initCanvas() {
    _context.clearRect(0, 0, _mapWidth, _mapHeight);
    _drawGrid();
  }

  void drawGraph(DisplayableGraph graph) {
    _initCanvas();
    _drawEdges(graph);
    _drawNodes(graph);
  }

  void drawPath(DisplayableGraph graph, {EdgeColorFunc edgeColorFn: null, NodeColorFunc nodeColorFn: null,
                                         NodeTextFunc nodeTextFn: null}) {
    _initCanvas();
    _drawEdges(graph, edgeColorFun: edgeColorFn);
    _drawNodes(graph, nodeColorFun: nodeColorFn, nodeTextFn: nodeTextFn);
  }


  void _drawGrid() {
    _context.beginPath();
    _context.strokeStyle = "#eee";
    for (int i = _cellWidth/2; i < _mapWidth; i += _cellWidth) {
      _context.moveTo(i, 0);
      _context.lineTo(i, _mapHeight);
    }
    for (int i = _cellHeight/2; i < _mapHeight; i += _cellHeight) {
      _context.moveTo(0, i);
      _context.lineTo(_mapWidth, i);
    }
    _context.stroke();
  }

  num _transformX(num x) => x * _cellWidth + _cellWidth/2;
  num _transformY(num y) => y * _cellHeight + _cellHeight/2;

  void _drawNodes(DisplayableGraph graph, {nodeColorFun: null, NodeTextFunc nodeTextFn: null}) {
    nodeColorFun = (nodeColorFun == null)? (_) => "gray" : nodeColorFun;
    nodeTextFn = (nodeTextFn == null)? (_) => "" : nodeTextFn;
    PList<Node> nodes = graph.graph.nodes;
    while(!nodes.isEmpty) {
      Node node = nodes.hd;
      EucNode eucNode = graph.euclidNodeFromId(node.id);
      _context.beginPath();
      var sx = _transformX(eucNode.x);
      var sy = _transformY(eucNode.y);
      _context.arc(sx, sy, 17, 0, PI*2, true);
      _context.closePath();
      _context.strokeStyle = "gray";
      _context.lineWidth = 2;
      _context.fillStyle
         = (node.id == 0) ? "lightgreen" // Start node
          : (node.id == graph.graph.nodeCount - 1) ? "#F17022" //end node
          : nodeColorFun(node);
      _context.fill();
      _context.stroke();

      _context.font = "Arial";
      _context.fillStyle = "black";
      _context.fillText(nodeTextFn(node), sx-8, sy+3);

      nodes = nodes.tl;
    }
  }

  void _drawEdges(DisplayableGraph graph, {EdgeColorFunc edgeColorFun: null}) {
    edgeColorFun = (edgeColorFun == null) ? (x, y) => "gray": edgeColorFun;
    for (Node srcNode in graph.graph.nodes) {
      EucNode eucNode = graph.euclidNodeFromId(srcNode.id);
      var eucNodeSX = _transformX(eucNode.x);
      var eucNodeSY = _transformY(eucNode.y);
      PList<Edge<Node>> edges = graph.graph.adjacent(srcNode);
      for (Edge<Node> edge in edges) {
        var dstNode = edge.dest;
        _context.beginPath();
        _context.strokeStyle = edgeColorFun(srcNode, dstNode);
        _context.lineWidth = 2;
        EucNode dstEucNode = graph.euclidNodeFromId(dstNode.id);
        var dstNodeSX = _transformX(dstEucNode.x);
        var dstNodeSY = _transformY(dstEucNode.y);
        _context.moveTo(eucNodeSX, eucNodeSY);
        _context.lineTo(dstNodeSX, dstNodeSY);
        _context.stroke();
      }
    }
  }

}
