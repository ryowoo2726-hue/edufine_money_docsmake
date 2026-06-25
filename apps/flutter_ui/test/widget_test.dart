import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui/main.dart';

void main() {
  testWidgets('renders money document workflow shell', (tester) async {
    await tester.pumpWidget(const MyApp());

    // Basic structural checks
    expect(find.text('품의서 생성기'), findsOneWidget);
    expect(find.text('견적서 업로드'), findsOneWidget);
  });
}
