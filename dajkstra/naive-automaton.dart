part of dajkstra;

/**
 * A state transition implementation of the naive search for a
 * shortest path. This implementation is derived directly from the
 * recursive descent search implemented in "naive.dart" using the
 * "functional correspondence" (Ager et al., PPDP'03).
 */
class NaiveAutomaton {

  Result findShortestPath(Graph graph) {
    return run(startStepping(graph));
  }

  State startStepping(Graph graph) {
    return new NodeState(graph.start,
                         new PList(),
                         0,
                         graph,
                         new EmptyContext());
  }

  // Run and print each state in the search for a shortest path.
  Result run(State state) {
    print(state);
    while (!(state is FinalState)) {
      state = state.step();
      print(state);
    }
    return state.result;
  }

}

abstract class State {
  State step();
  dynamic match({
      dynamic onCycle(CycleState),
      dynamic onPath(PathState),
      dynamic onFinal(FinalState),
      dynamic onNode(NodeState),
      dynamic onEdges(EdgesState),
      dynamic onCont(ContState)
  });
}

class CycleState extends State {
  PList<Node> cyclePath;
  ContState cont;
  CycleState(this.cyclePath, this.cont);
  State step() => cont;
  String toString() => "CYCLE";
  dynamic match({
      dynamic onCycle(CycleState),
      dynamic onPath(PathState),
      dynamic onFinal(FinalState),
      dynamic onNode(NodeState),
      dynamic onEdges(EdgesState),
      dynamic onCont(ContState)
  }) => onCycle(this);
}

class PathState extends State {
  ContState cont;
  PathState(this.cont);
  State step() => cont;
  String toString() => "FOUND PATH(${cont.result.cost})";
  dynamic match({
      dynamic onCycle(CycleState),
      dynamic onPath(PathState),
      dynamic onFinal(FinalState),
      dynamic onNode(NodeState),
      dynamic onEdges(EdgesState),
      dynamic onCont(ContState)
  }) => onPath(this);
}

class FinalState extends State {
  Result result;
  FinalState(this.result);
  State step() => this;
  String toString() => "FINAL($result)";
  dynamic match({
      dynamic onCycle(CycleState),
      dynamic onPath(PathState),
      dynamic onFinal(FinalState),
      dynamic onNode(NodeState),
      dynamic onEdges(EdgesState),
      dynamic onCont(ContState)
  }) => onFinal(this);
}

class NodeState extends State {
  Node currentNode;
  PList<Node> currentPath;
  num currentCost;
  Graph graph;
  Context cont;
  NodeState(this.currentNode,
            this.currentPath,
            this.currentCost,
            this.graph,
            this.cont);
  State step() {
    var currentFullPath = currentPath.cons(currentNode);
    return (currentNode.id == graph.end.id)
        ? new PathState(new ContState(cont, new Result(currentFullPath, currentCost)))
        : ((currentPath.any((elm) => elm.id == currentNode.id))
           ? new CycleState(currentFullPath, new ContState(cont, new Result.NoPath()))
           : new EdgesState(graph.adjacent(currentNode),
                            new Result.NoPath(),
                            currentFullPath,
                            currentCost,
                            graph,
                            cont));
  }
  String toString() => "NODE($currentNode, $currentCost, $currentPath)";
  dynamic match({
      dynamic onCycle(CycleState),
      dynamic onPath(PathState),
      dynamic onFinal(FinalState),
      dynamic onNode(NodeState),
      dynamic onEdges(EdgesState),
      dynamic onCont(ContState)
  }) => onNode(this);
}

class EdgesState extends State {
  PList<Edge> edges;
  Result bestRes;
  PList<Node> currentFullPath;
  num currentCost;
  Graph graph;
  Context cont;
  EdgesState(this.edges,
             this.bestRes,
             this.currentFullPath,
             this.currentCost,
             this.graph,
             this.cont);
  State step() {
    return (edges.isEmpty)
      ? new ContState(cont, bestRes)
      : (!currentFullPath.tl.isEmpty && edges.hd.dest == currentFullPath.tl.hd)
        ? new EdgesState(edges.tl, bestRes, currentFullPath, currentCost, graph, cont).step()
          : new NodeState(edges.hd.dest,
                          currentFullPath,
                          currentCost + edges.hd.cost,
                          graph,
                          new EdgesContext(edges,
                                           bestRes,
                                           currentFullPath,
                                           currentCost,
                                           graph,
                                           cont));
  }
  String toString() => "EDGES($edges)";
  dynamic match({
      dynamic onCycle(CycleState),
      dynamic onPath(PathState),
      dynamic onFinal(FinalState),
      dynamic onNode(NodeState),
      dynamic onEdges(EdgesState),
      dynamic onCont(ContState)
  }) => onEdges(this);
}

class ContState extends State {
  Context cont;
  Result result;
  ContState(this.cont, this.result);
  State step() => cont.apply(result);
  String toString() => "CONTEXT($cont)";
  dynamic match({
      dynamic onCycle(CycleState),
      dynamic onPath(PathState),
      dynamic onFinal(FinalState),
      dynamic onNode(NodeState),
      dynamic onEdges(EdgesState),
      dynamic onCont(ContState)
  }) => onCont(this);
}

abstract class Context {
  State apply(Result result);
  dynamic foldr(dynamic fn(EdgesContext, dynamic), dynamic acc);
}

class EmptyContext extends Context {
  State apply(Result result) => new FinalState(result);
  String toString() => "EMPTY";
  dynamic foldr(dynamic fn(EdgesContext, dynamic), dynamic acc) => acc;
}

class EdgesContext extends Context {
  PList<Edge> edges;
  Result bestRes;
  PList<Node> currentFullPath;
  num currentCost;
  Graph graph;
  Context cont;
  EdgesContext(this.edges,
               this.bestRes,
               this.currentFullPath,
               this.currentCost,
               this.graph,
               this.cont);
  State apply(Result result) =>
      new EdgesState(edges.tl,
                     (result.cost < bestRes.cost) ? result : bestRes,
                     currentFullPath,
                     currentCost,
                     graph,
                     cont);
  String toString() => "NON-EMPTY";
  dynamic foldr(dynamic fn(EdgesContext, dynamic), dynamic acc) => fn(this, cont.foldr(fn, acc));
}
