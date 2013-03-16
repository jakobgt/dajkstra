FILES=main.dart graph.dart plist.dart naive.dart visualizer.dart visualizer.dart
MAIN=main
VISUALIZER=visualizer
DART=dart
DART2JS=dart2js
BUILD=build

build-dir:
	mkdir -p $(BUILD)

$(VISUALIZER): $(VISUALIZER).js

$(VISUALIZER).js: $(FILES) build-dir
	$(DART2JS) $(VISUALIZER).dart --minify -c -p. -o$(BUILD)/$(VISUALIZER).js

default:
	$(DART) --checked --package-root=./ $(MAIN).dart
