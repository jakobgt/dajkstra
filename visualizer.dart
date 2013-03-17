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

const easyGraph = 3;

const hardGraph = 50;

void main() {
  print("Running main");
// An empty timer in order to avoid null values.var timer = new Timer(new Duration(seconds: 0), () {
}

);

ShortestPathDriver resetGraph(int graphComplexity) {
  timer.cancel();
  return new ShortestPathDriver(query("#map"), nodeCount, xmax, ymax, mapWidthMax, mapHeightMax)..generateGraph(graphComplexity);
}

var driver = resetGraph(easyGraph);

// Setting up buttons.query("#btn_reset").onClick.listen((e) => driver.resetPath());

query

(

"



#btn_easy_map



"

)

.

onClick

.

listen

(

(

e

)

{

driver

=

resetGraph

(

easyGraph

);

}

);

query

(

"



#btn_hard_map



"

)

.

onClick

.

listen

(

(

e

)

{

driver

=

resetGraph

(

hardGraph

);

}

);

query

(

"



#btn_naive_step



"

)

.

onClick

.

listen

(

(

e

)

=>

driver

.

takeNaiveStep

(

)

);

query

(

"



#btn_naive_run



"

)

.

onClick

.

listen

(

(

e

)

{

timer

=

driver

.

runNaive

(

runSpeed

);

}

);

}

class

ShortestPathDriver

{

num

_nodeCount;

num

_xmax;

num

_ymax;

GraphGenerator

_graphGenerator

=

new

GraphGenerator

(

);

NaiveAlgorithm

_naiveAlgorithm

=

new

NaiveAlgorithm

(

);

GraphPainter

_graphPainter;

DisplayableGraph

_graph;

State

_state;

Timer

_timer

=

new

Timer

(

new

Duration

(

seconds

:

0

)

,

(

)

{

}

);

//Default timer to avoid null

ShortestPathDriver

(

CanvasElement

canvasElement

,

this

.

_nodeCount

,

this

.

_xmax

,

this

.

_ymax

,

mapWidthMax

,

mapHeightMax

)

{

_graphPainter

=

new

GraphPainter

(

canvasElement

,

_xmax

,

_ymax

,

mapWidthMax

,

mapHeightMax

);

}

void

generateGraph

(

num

numberOfRoutes

)

{

int

nrOfPaths

=

0;

DisplayableGraph

graph;

do

{

nrOfPaths

=

0;

graph

=

_graphGenerator

.

generateGraph

(

_nodeCount

,

_xmax

,

_ymax

);

_naiveAlgorithm

.

findShortestPath

(

_graph

.

graph

,

onPath

:

(

_

)

=>

nrOfPaths

++

);

}

while

(

nrOfPaths

<

numberOfRoutes

);

_graph

=

graph;

_graphPainter

.

drawGraph

(

_graph

);

}

void

resetPath

(

)

{

_state

=

null;

_timer

.

cancel

(

);

_graphPainter

.

drawGraph

(

_graph

);

}

// Takes a step and repaint the graph with the given path.

// It returns true, when there are no more steps to take.

bool

takeNaiveStep

(

)

{

if

(

_state

==

null

)

_state

=

new

NaiveAutomaton

(

)

.

startStepping

(

_graph

.

graph

);

do

{

_state

=

_state

.

step

(

);

}

while

(

!

(

_state

is

FinalState

)

&&

!

(

_state

is

NodeState

)

);

PList

<

Node

>

path

=

(

_state

is

FinalState

)

?

(

_state

as

FinalState

)

.

result

.

path

:

(

_state

as

NodeState

)

.

currentPath

.

cons

(

(

_state

as

NodeState

)

.

currentNode

);

_graphPainter

.

drawPath

(

_graph

,

path

);

print

(

path

);

return

(

_state

is

FinalState

);

}

// Calls takeNaiveStep succesively until it stops (with a delay of speed ms).

// Returns the timer that handles the call to takeNaiveStep.

Timer

runNaive

(

int

speed

)

{

_timer

=

new

Timer

.

repeating

(

new

Duration

(

milliseconds

:

speed

)

,

(

Timer

timer

)

{

if

(

takeNaiveStep

(

)

)

{

timer

.

cancel

(

);

}

}

);

return

_timer;

}

}