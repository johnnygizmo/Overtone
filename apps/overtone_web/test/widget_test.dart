import 'package:flutter_test/flutter_test.dart';
import 'package:overtone_web/main.dart';

void main() {
  testWidgets('app shows the title', (tester) async {
    await tester.pumpWidget(const OvertoneApp());
    expect(find.text('Overtone'), findsOneWidget);
  });
}
