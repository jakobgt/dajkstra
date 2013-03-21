DAJKSTRADIR=dajkstra
DAJKSTRALIB=$(DAJKSTRADIR)/dajkstra.dart $(DAJKSTRADIR)/graph-generator.dart $(DAJKSTRADIR)/graph.dart $(DAJKSTRADIR)/naive-automaton.dart $(DAJKSTRADIR)/naive.dart $(DAJKSTRADIR)/plist.dart
FILES=main.dart visualizer.dart visualizer.dart $(DAJKSTRALIB)
MAIN=main
VISUALIZER=visualizer
CODEJUMPER=code-jumper
DART=dart
DART2JS=dart2js
BUILD=build
NAIVESIMPLE=dajkstra/naive-simple.dart
EXAMPLEDIR=example

publish: $(VISUALIZER)
	mkdir -p $(EXAMPLEDIR)
	cp $(BUILD)/$(VISUALIZER).dart.* $(EXAMPLEDIR)/
	cp $(BUILD)/$(CODEJUMPER).dart.* $(EXAMPLEDIR)/
	cp *.css $(EXAMPLEDIR)/
	cp naive-simple.html $(EXAMPLEDIR)/
	sed -E s_build/__ index.html > $(EXAMPLEDIR)/index.html
	sed -E s_build/__ $(CODEJUMPER).html > $(EXAMPLEDIR)/$(CODEJUMPER).html
	scp $(EXAMPLEDIR)/* gedefar@fh.cs.au.dk:~/public_html/shortest-path

build-dir:
	mkdir -p $(BUILD)

$(VISUALIZER): $(VISUALIZER).js

$(VISUALIZER).js: $(FILES) build-dir
	$(DART2JS) $(VISUALIZER).dart -c -p. -o$(BUILD)/$(VISUALIZER).dart.js
	$(DART2JS) $(CODEJUMPER).dart -c -p. -o$(BUILD)/$(CODEJUMPER).dart.js

htmlSimple:
	pygmentize -f html -o naive-simple-tmp.html $(NAIVESIMPLE)
	sed -E  's_// ([a-zA-Z]+State):_// <a name="\1">\1:</a>_g' naive-simple-tmp.html > naive-simple.html
	rm naive-simple-tmp.html

default:
	$(DART) --checked --package-root=./ $(MAIN).dart
