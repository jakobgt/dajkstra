/**
*  This file is used to run the algorithms in the browser.
*/

import 'dart:html' show query, CanvasElement, HTMLInputElement;
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

void disableDijkstra() {
  query("#btn_dijkstra_step").disabled = true;
  query("#btn_dijkstra_run").disabled = true;
}

void disableNaive() {
  query("#btn_naive_step").disabled = true;
  query("#btn_naive_run").disabled = true;
}

void main() {
  print("Running main");
  var buttons = ["#btn_reset", "#btn_easy_map", "#btn_hard_map", "#btn_naive_step",
                 "#btn_naive_run", "#btn_dijkstra_step", "#btn_dijkstra_run"];
  buttons = new List.from(buttons.map((String s) => query(s)));
  print(buttons);
  buttons[0].disabled = true;
  enableAllButtons() => new List.from(buttons.map((var elm) => elm.disabled = false));
  // An empty timer in order to avoid null values.
  var timer = new Timer(new Duration(seconds: 0), () {});
  ShortestPathDriver resetGraph(int graphComplexity) {
    timer.cancel();
    enableAllButtons();
    return new ShortestPathDriver(query("#map"), nodeCount,
        xmax, ymax, mapWidthMax, mapHeightMax)..generateGraph(graphComplexity);
  }
  var driver = resetGraph(easyGraph);
  // Setting up buttons.
  query("#btn_reset").onClick.listen((e) {
    enableAllButtons();
    driver.resetPath();
  });
  query("#btn_easy_map").onClick.listen((e) {driver = resetGraph(easyGraph); });
  query("#btn_hard_map").onClick.listen((e) {driver = resetGraph(hardGraph); });
  query("#btn_naive_step").onClick.listen((e) {
    disableDijkstra();
    driver.takeNaiveStep();
  });
  bool runningNaive = false;
  query("#btn_naive_run").onClick.listen((e) {
    var button = query("#btn_naive_run");
    disableDijkstra();
    timer.cancel();
    if (runningNaive) {
      timer.cancel();
      button.value = "Run Naive";
      runningNaive = false;
    } else {
      timer = driver.runNaive(driver.takeNaiveStep, runSpeed);
      button.value = "Stop naive run";
      runningNaive = true;
    }
  });

  query("#btn_dijkstra_step").onClick.listen((e) {
    disableNaive();
    driver.takeDijkstraStep();
  });
  bool runningDijkstra = false;
  query("#btn_dijkstra_run").onClick.listen((e) {
    var button = query("#btn_dijkstra_run");
    disableNaive();
    timer.cancel();
    if (runningDijkstra) {
      timer.cancel();
      button.value = "Run Dijkstra";
      runningDijkstra = false;
    } else {
      //Dijkstras should run a little slower, because it does not have as many steps.
      timer = driver.runNaive(driver.takeDijkstraStep, 2* runSpeed);
      button.value = "Stop Dijkstra run";
      runningDijkstra = true;
    }
  });

}

class ShortestPathDriver {
  num _nodeCount;
  num _xmax;
  num _ymax;

  GraphGenerator _graphGenerator = new GraphGenerator();
  NaiveAlgorithm _naiveAlgorithm = new NaiveAlgorithm();
  DijkstraAlgorithm _dijkstraAlgorithm;
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
    _dijkstraAlgorithm = new DijkstraAlgorithm(_graph.graph);
  }

  void resetPath() {
    _state = null;
    _timer.cancel();
    _graphPainter.drawGraph(_graph);
    _dijkstraAlgorithm = new DijkstraAlgorithm(_graph.graph);
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
    if (list.isEmpty) return new PList();
    else {
      return list.hd.foldr((e, acc) => acc.cons(e), flatten(list.tl));
    }
  }

  PList<Node> _extractCycle(PList<Node> cycle) {
    Node head = cycle.hd;
    PList<Node> visit(PList<Node> cycle) {
      if (cycle.isEmpty) {
        throw new Exception("Did not find the $head in the list, which is an error, as it is a cycle");
      } else if (cycle.hd == head) {
        return new PList().cons(cycle.hd);
      } else {
        return visit(cycle.tl).cons(cycle.hd);
      }
    }
    return visit(cycle.tl).cons(head);
  }

  // Calls fn succesively until it stops (with a delay of speed ms).
  // Returns the timer that handles the call to takeNaiveStep.
  Timer runNaive(bool fn(), int speed) {
    _timer = new Timer.repeating(new Duration(milliseconds: speed), (Timer timer) {
      if (fn()) {
        timer.cancel();
      }
    });
    return _timer;
  }

  bool takeDijkstraStep() {
    var currentEndNode = _dijkstraAlgorithm.takeStep();
    PList<Node> currentPath = _dijkstraAlgorithm.getPath(currentEndNode);
    print(currentPath);
    String pathColor = (currentEndNode == _graph.graph.end) ? "lightgreen" : "blue";
    _graphPainter.drawPath(_graph,
      edgeColorFn: (Node src, Node dst) =>
        (visit(currentPath, src, dst))
          ? pathColor : "gray",
    nodeColorFn: (Node n) =>
      _dijkstraAlgorithm.visited.contains(n) ? "white"
        : _dijkstraAlgorithm.allCosts[n] != double.INFINITY ? "lightblue" : "gray",
    nodeTextFn: (Node n) =>
      _dijkstraAlgorithm.allCosts[n] != double.INFINITY ? "${(_dijkstraAlgorithm.allCosts[n]*10).floor()/10}" : "");
    return (currentEndNode == _graph.graph.end);
  }

  bool visit(PList<Node> path, Node src, Node dst) {
    if (path.isEmpty) return false;
    // Remember that the graph is undirected
    if (path.hd == dst && !path.tl.isEmpty && path.tl.hd == src ||
        path.hd == src && !path.tl.isEmpty && path.tl.hd == dst) return true;
    else return visit(path.tl, src, dst);
  }

  bool visitEdges(PList<Edge> edges, Node src, Node dst) {
    return edges.any((Edge otherE) => otherE.src == src && otherE.dest == dst ||
    otherE.src == dst && otherE.dest == src);
  }

  // Takes a step and repaint the graph with the given path.
  // It returns true, when there are no more steps to take.
  bool takeNaiveStep() {
    if (_state == null) _state = new NaiveAutomaton().startStepping(_graph.graph);
    _state = _state.step();
    dynamic idFun(dynamic x) => x;
    // If we have a EdgesState we continue;
    _state = _state.match(onEdges: (state) => _state.step(), onCycle: idFun, onPath: idFun, onFinal: idFun,
                          onNode: idFun, onCont: idFun);
    PList<Node> currentPath = new PList();
    PList<Node> cycle = new PList();
    PList<Node> endPath = new PList();
    Context context = new EmptyContext();
    Map<Node, num> nodeCosts = new Map();
    _state.match(
        onCycle: (state) {
                   context = state.cont.cont;
                   currentPath = state.cyclePath;
                   cycle = _extractCycle(currentPath);
                 },
        onPath: (state) {
                   context = state.cont.cont;
                   Result result = state.cont.result;
                   currentPath = result.path;
                   nodeCosts[result.path.hd] = result.cost;
                   endPath = currentPath;
                 },
        onFinal: (state) {
                   Result result = state.result;
                   currentPath = result.path;
                   nodeCosts[_graph.graph.end] = result.cost;
                   endPath = currentPath;
                 },
        onNode: (state) {
                   context = state.cont;
                   currentPath = state.currentPath.cons(state.currentNode);
                 },
        onEdges: (state) {
                   context = state.cont;
                   currentPath = state.currentFullPath;
                 },
        onCont: (state) {
                   context = state.cont;
                   currentPath = _extractPath(state.cont);
                 }
    );
    PList<Edge> todoEdges = flatten(_extractEdgesToDo(context));

    context.foldr((EdgesContext e, _) {
      nodeCosts[e.currentFullPath.hd] = e.currentCost;
    }, []);

    _graphPainter.drawPath(_graph,
        edgeColorFn: (Node src, Node dst) =>
        (visit(cycle, src, dst))
          ? "red" : (visit(endPath, src, dst))
            ? "green" : (visit(currentPath, src, dst))
              ? "blue" : (visitEdges(todoEdges, src, dst))
                ? "lightblue" : "gray",
        nodeColorFn: (Node n) =>
          (currentPath.any((Node other) => n.id == other.id))? "white": "gray",
        nodeTextFn: (Node n) => nodeCosts.containsKey(n) ? "${(nodeCosts[n]*10).floor()/10}" : "");
    print(currentPath);
    return (_state is FinalState);
  }

}
