FILES=main.dart graph.dart plist.dart naive.dart
MAIN=main.dart
DART=dart

default:
	$(DART) --checked $(MAIN)
