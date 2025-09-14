import 'package:flutter_test/flutter_test.dart';

import 'package:syntax_sprint/main.dart';

void main() {
  testWidgets('renders hint text', (WidgetTester tester) async {
    await tester.pumpWidget(const SyntaxSprintApp());
    expect(
      find.text('Add more concepts by editing SNIPPETS in concept.dart'),
      findsOneWidget,
    );
  });
}
