import 'package:flutter_test/flutter_test.dart';
import 'package:app_acre_24h_front/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Acre24hApp full render test', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint("FLUTTER ERROR: ${details.exception}");
      debugPrint("${details.stack}");
    };

    try {
      const app = Acre24hApp();
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      bool isRendered = find.text('Entrar').evaluate().isNotEmpty;
      debugPrint("Render complete! Found 'Entrar': $isRendered");
    } catch (e, stack) {
      debugPrint("FATAL RENDER CRASH: $e\n$stack");
    }
  });
}
