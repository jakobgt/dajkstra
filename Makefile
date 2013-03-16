FILES=main.dart graph.dart plist.dart naive.dart visualizer.dart visualizer.dart
MAIN=main
VISUALIZER=visualizer
DART=dart
DART2JS=dart2js

$(VISUALIZER): $(VISUALIZER).js

$(VISUALIZER).js: $(FILES)
	$(DART2JS) $(VISUALIZER).dart --minify -c -p. -o$(VISUALIZER).js


default:
	$(DART) --checked $(MAIN).dart
