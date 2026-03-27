import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_acre_24h_front/main.dart';
import 'package:app_acre_24h_front/screens/home_screen.dart';

void main() {
  testWidgets('App renders correctly smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: Acre24hApp()));

    // Verify that our HomeScreen is rendered.
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
