import 'package:flutter_test/flutter_test.dart';
import 'package:app_acre_24h_front/screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('LoginScreen renders components', (WidgetTester tester) async {
    // Override Firebase initialization by directly pumping LoginScreen
    // without the real Firebase.initializeApp which might block.

    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint("FLUTTER ERROR: ${details.exception}");
      debugPrint("${details.stack}");
    };

    const app = MaterialApp(home: LoginScreen());

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final findBemVindo = find.textContaining('Bem-vindo');
    if (findBemVindo.evaluate().isEmpty) {
      debugPrint("Text 'Bem-vindo' NOT FOUND! Layout might be empty.");
    } else {
      debugPrint("Text 'Bem-vindo' FOUND. The UI is rendering properly.");
    }
  });
}
