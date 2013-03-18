/**
*  This file is used to run the algorithms in the browser.
*/

import 'dart:html' show query, CanvasElement;
import 'dart:async';
import 'dajkstra/dajkstra.dart';
import 'graph-painter.dart';

var scale = 1;
var nodeCount = 50 * scale;
var xmax = 18 * scale;
var ymax = 12 * scale;
var mapWidthMax = 900 * scale;
var mapHeightMax = 600 * scale;
var runSpeed = 100;

const easyGraph = 1;
const hardGraph = 30;

void main() {
  print("Running main");
  // An empty timer in order to avoid null values.
  var timer = new Timer(new Duration(seconds: 0), () {});
  ShortestPathDriver resetGraph(int graphComplexity) {
    timer.cancel();
    return new ShortestPathDriver(query("#map"), nodeCount,
        xmax, ymax, mapWidthMax, mapHeightMax)..generateGraph(graphComplexity);
  }
  var driver = resetGraph(easyGraph);
  // Setting up buttons.
  query("#btn_reset").onClick.listen((e) => driver.resetPath());
  query("#btn_easy_map").onClick.listen((e) {driver = resetGraph(easyGraph); });
  query("#btn_hard_map").onClick.listen((e) {driver = resetGraph(hardGraph); });
  query("#btn_naive_step").onClick.listen((e) => driver.takeNaiveStep());
  query("#btn_naive_run").onClick.listen((e) {timer = driver.runNaive(runSpeed);});
}

class ShortestPathDriver {
  num _nodeCount;
  num _xmax;
  num _ymax;

  GraphGenerator _graphGenerator = new GraphGenerator();
  NaiveAlgorithm _naiveAlgorithm = new NaiveAlgorithm();
  GraphPainter _graphPainter;

  DisplayableGraph _graph;
  State _state;
  Timer _timer = new Timer(new Duration(seconds: 0), () {}); //Default timer to avoid null

  ShortestPathDriver(CanvasElement canvasElement, this._nodeCount, this._xmax, this._ymax,
                     mapWidthMax, mapHeightMax) {
    _graphPainter = new GraphPainter(canvasElement, _xmax, _ymax, mapWidthMax, mapHeightMax);
  }

  void generateGraph(num numberOfRoutes) {
    int nrOfPaths = 0;
    DisplayableGraph graph = null;
    do {
      nrOfPaths = 0;
      graph = _graphGenerator.generateGraph(_nodeCount, _xmax, _ymax);
      _naiveAlgorithm.findShortestPath(graph.graph, onPath: (_) => nrOfPaths++);
    } while (nrOfPaths < numberOfRoutes);
    _graph = graph;
    _graphPainter.drawGraph(_graph);
  }

  void resetPath() {
    _state = null;
    _timer.cancel();
    _graphPainter.drawGraph(_graph);
  }

  PList<Node> _extractPath(Context cont) {
    if (cont is EmptyContext)
      return new PList();
    else {
      var context = (cont as EdgesContext);
      return context.currentFullPath;
    }
  }

  PList<PList<Edge>> _extractEdgesToDo(Context cont) {
    if (cont is EmptyContext) {
      return new PList();
    } else {
      return _extractEdgesToDo(cont.cont).cons(cont.edges);
    }
  }

  PList flatten(PList<PList> list) {
    if (list.empty) return new PList();
    else {
      return list.hd.foldr((e, acc) => acc.cons(e), flatten(list.tl));
    }
  }

  PList<Node> _extractCycle(PList<Node> cycle) {
    Node head = cycle.hd;
    PList<Node> visit(PList<Node> cycle) {
      if (cycle.empty) {
        throw new Exception("Did not find the $head in the list, which is an error, as it is a cycle");
      } else if (cycle.hd == head) {
        return new PList().cons(cycle.hd);
      } else {
        return visit(cycle.tl).cons(cycle.hd);
      }
    }
    return visit(cycle.tl).cons(head);
  }

  // Takes a step and repaint the graph with the given path.
  // It returns true, when there are no more steps to take.
  bool takeNaiveStep() {
    if (_state == null) _state = new NaiveAutomaton().startStepping(_graph.graph);
    _state = _state.step();
    PList<Node> currentPath = new PList();
    PList<Node> cycle = new PList();
    PList<Node> endPath = new PList();
    Context context = new EmptyContext();
    Map<Node, num> nodeCosts = new Map();
    if (_state is CycleState) {
      context = (_state as CycleState).cont.cont;
      currentPath = (_state as CycleState).cyclePath;
      cycle = _extractCycle(currentPath);
    } else if (_state is PathState) {
      context = (_state as PathState).cont.cont;
      Result result = (_state as PathState).cont.result;
      currentPath = result.path;
      nodeCosts[result.path.hd] = result.cost;
      endPath = currentPath;
    } else if (_state is FinalState) {
      Result result = (_state as FinalState).result;
      currentPath = result.path;
      nodeCosts[_graph.graph.end] = result.cost;
      endPath = currentPath;
    } else if (_state is NodeState) {
      context = (_state as NodeState).cont;
      currentPath = (_state as NodeState).currentPath.cons((_state as NodeState).currentNode);
    } else if (_state is EdgesState) {
      context = (_state as EdgesState).cont;
      currentPath = (_state as EdgesState).currentFullPath;
    } else if (_state is ContState) {
      context = (_state as ContState).cont;
      currentPath = _extractPath((_state as ContState).cont);
    }
    PList<Edge> todoEdges = flatten(_extractEdgesToDo(context));

    context.foldr((EdgesContext e, _) {
      nodeCosts[e.currentFullPath.hd] = e.currentCost;
    }, []);

    bool visit(PList<Node> path, Node src, Node dst) {
      if (path.empty) return false;
      // Remember that the graph is undirected
      if (path.hd == dst && !path.tl.empty && path.tl.hd == src ||
          path.hd == src && !path.tl.empty && path.tl.hd == dst) return true;
      else return visit(path.tl, src, dst);
    }
    bool visitEdges(PList<Edge> edges, Node src, Node dst) {
      return edges.any((Edge otherE) => otherE.src == src && otherE.dest == dst ||
                                        otherE.src == dst && otherE.dest == src);
    }

    _graphPainter.drawPath(_graph,
        edgeColorFn: (Node src, Node dst) =>
        (visit(cycle, src, dst))
          ? "red" : (visit(endPath, src, dst))
            ? "green" : (visit(currentPath, src, dst))
              ? "blue" : (visitEdges(todoEdges, src, dst))
                ? "gray" : "lightgray",
        nodeColorFn: (Node n) =>
          (currentPath.any((Node other) => n.id == other.id))? "white": "gray",
        nodeTextFn: (Node n) => nodeCosts.containsKey(n) ? "${(nodeCosts[n]*10).floor()/10}" : "");
    print(currentPath);
    return (_state is FinalState);
  }

  // Calls takeNaiveStep succesively until it stops (with a delay of speed ms).
  // Returns the timer that handles the call to takeNaiveStep.
  Timer runNaive(int speed) {
    _timer = new Timer.repeating(new Duration(milliseconds: speed), (Timer timer) {
      if (takeNaiveStep()) {
        timer.cancel();
      }
    });
    return _timer;
  }
}