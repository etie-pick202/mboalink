import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mboalink/main.dart';

void main() {
  testWidgets('App boots and shows setup screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MboaLinkApp()));

    expect(find.text('MboaLink — setup OK'), findsOneWidget);
  });
}
