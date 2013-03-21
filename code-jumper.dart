import 'dart:html';
import 'dart:json';

void updateHighlightedElements() {
  Location loc = window.location;
  for (Element elm in document.queryAll("div, a")) {
    elm.classes.clear();
  }
  if (!loc.hash.isEmpty) {
    String hash = loc.hash.substring(1);
    query("#$hash").classes.add("highlighted");
  }
}

void main() {
  window.onHashChange.listen((e) => updateHighlightedElements());
  updateHighlightedElements();
}