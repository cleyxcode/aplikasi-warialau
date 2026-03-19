import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_sd/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
  });
}
