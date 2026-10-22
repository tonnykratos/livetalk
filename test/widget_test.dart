import 'package:flutter_test/flutter_test.dart';
import 'package:livetalk/main.dart';

void main() {
  testWidgets('LiveTalkApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LiveTalkApp());

    // Verify app title / header is present
    expect(find.text('LiveTalk 🔴 (TikTok Live & Spaces)'), findsOneWidget);
  });
}
