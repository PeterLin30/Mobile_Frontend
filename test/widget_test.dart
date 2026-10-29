import 'package:flutter_test/flutter_test.dart';
import 'package:mikrohub/main.dart';

void main() {
  testWidgets('MikroHub app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MikroHubApp());

    expect(find.byType(MikroHubApp), findsOneWidget);
  });
}