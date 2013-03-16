DAJKSTRADIR=dajkstra
DAJKSTRALIB=$(DAJKSTRADIR)/dajkstra.dart $(DAJKSTRADIR)/graph-generator.dart $(DAJKSTRADIR)/graph.dart $(DAJKSTRADIR)/naive-automaton.dart $(DAJKSTRADIR)/naive.dart $(DAJKSTRADIR)/plist.dart
FILES=main.dart visualizer.dart visualizer.dart $(DAJKSTRALIB)
MAIN=main
VISUALIZER=visualizer
DART=dart
DART2JS=dart2js
BUILD=build

build-dir:
	mkdir -p $(BUILD)

$(VISUALIZER): $(VISUALIZER).js

$(VISUALIZER).js: $(FILES) build-dir
	$(DART2JS) $(VISUALIZER).dart --minify -c -p. -o$(BUILD)/$(VISUALIZER).dart.js

default:
	$(DART) --checked --package-root=./ $(MAIN).dart
