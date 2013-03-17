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

  void drawPath(DisplayableGraph graph, PList<Node> path) {
    _initCanvas();
    _drawEdges(graph);
    _drawPath(graph, path);
    // Nodes that are in the path are colored white. All other gray (except start and end)
    _drawNodes(graph, colorFun: (Node n) =>
        (path.any((Node other) => n.id == other.id))? "white": "gray");
  }

  void _drawPath(DisplayableGraph graph, PList<Node> path) {
    if (path.empty) return;
    _context.beginPath();
    _context.strokeStyle = "lightgreen";
    _context.lineWidth = 5;
    path.foldr((node, acc) {
      var eucNode = graph.euclidNodeFromId(node.id);
      if (acc) {
        _context.moveTo(_transformX(eucNode.x), _transformY(eucNode.y));
      } else {
        _context.lineTo(_transformX(eucNode.x), _transformY(eucNode.y));
      }
      return false;
    }, true); // Acc states whether it is the first
    _context.stroke();
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

  void _drawNodes(DisplayableGraph graph, {colorFun: null}) {
    colorFun = (colorFun == null)? (_) => "gray" : colorFun;
    PList<Node> nodes = graph.graph.nodes;
    while(!nodes.empty) {
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
          : colorFun(node);
      _context.fill();
      _context.stroke();
      nodes = nodes.tl;
    }
  }

  void _drawEdges(DisplayableGraph graph) {
    graph.graph.nodes.map((Node srcNode) {
      EucNode eucNode = graph.euclidNodeFromId(srcNode.id);
      var eucNodeSX = _transformX(eucNode.x);
      var eucNodeSY = _transformY(eucNode.y);
      PList<Edge<Node>> edges = graph.graph.adjacent(srcNode);
      edges.map((Edge<Node> edge) {
        var dstNode = edge.dest;
        _context.beginPath();
        _context.strokeStyle = "gray";
        _context.lineWidth = 2;
        EucNode dstEucNode = graph.euclidNodeFromId(dstNode.id);
        var dstNodeSX = _transformX(dstEucNode.x);
        var dstNodeSY = _transformY(dstEucNode.y);
        _context.moveTo(eucNodeSX, eucNodeSY);
        _context.lineTo(dstNodeSX, dstNodeSY);
        _context.stroke();
      });
    });
  }

}
