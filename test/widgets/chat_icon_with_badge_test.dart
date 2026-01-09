import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/widgets/home_screen/chat_icon_with_badge.dart';

import '../helpers/mock_providers.dart';

void main() {
  group('ChatIconWithBadge', () {
    late MockChatProvider mockChatProvider;
    late MockVoidCallback mockOnPressed;

    setUp(() {
      mockChatProvider = MockChatProvider();
      mockOnPressed = MockVoidCallback();
    });

    Future<void> pumpChatIconWithBadge(WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ChatProvider>.value(
          value: mockChatProvider,
          child: MaterialApp(
            home: Scaffold(
              body: ChatIconWithBadge(onPressed: mockOnPressed.call),
            ),
          ),
        ),
      );
    }

    testWidgets('renders correctly', (tester) async {
      when(() => mockChatProvider.hasUnreadMessages).thenReturn(false);
      when(() => mockChatProvider.totalUnreadCount).thenReturn(0);

      await pumpChatIconWithBadge(tester);

      expect(find.byType(ChatIconWithBadge), findsOneWidget);
    });

    testWidgets('displays mail icon', (tester) async {
      when(() => mockChatProvider.hasUnreadMessages).thenReturn(false);
      when(() => mockChatProvider.totalUnreadCount).thenReturn(0);

      await pumpChatIconWithBadge(tester);

      expect(find.byIcon(Icons.mail_rounded), findsOneWidget);
    });

    testWidgets('shows no badge when no unread messages', (tester) async {
      when(() => mockChatProvider.hasUnreadMessages).thenReturn(false);
      when(() => mockChatProvider.totalUnreadCount).thenReturn(0);

      await pumpChatIconWithBadge(tester);

      // No badge text should be shown
      expect(find.text('0'), findsNothing);
    });

    testWidgets('shows badge with count when has unread messages', (
      tester,
    ) async {
      when(() => mockChatProvider.hasUnreadMessages).thenReturn(true);
      when(() => mockChatProvider.totalUnreadCount).thenReturn(5);

      await pumpChatIconWithBadge(tester);

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows 99+ when unread count exceeds 99', (tester) async {
      when(() => mockChatProvider.hasUnreadMessages).thenReturn(true);
      when(() => mockChatProvider.totalUnreadCount).thenReturn(150);

      await pumpChatIconWithBadge(tester);

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      when(() => mockChatProvider.hasUnreadMessages).thenReturn(false);
      when(() => mockChatProvider.totalUnreadCount).thenReturn(0);

      await pumpChatIconWithBadge(tester);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      verify(() => mockOnPressed.call()).called(1);
    });

    testWidgets('has Messages tooltip', (tester) async {
      when(() => mockChatProvider.hasUnreadMessages).thenReturn(false);
      when(() => mockChatProvider.totalUnreadCount).thenReturn(0);

      await pumpChatIconWithBadge(tester);

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.tooltip, 'Messages');
    });

    testWidgets('badge is red colored', (tester) async {
      when(() => mockChatProvider.hasUnreadMessages).thenReturn(true);
      when(() => mockChatProvider.totalUnreadCount).thenReturn(3);

      await pumpChatIconWithBadge(tester);

      final container = tester.widget<Container>(
        find
            .ancestor(of: find.text('3'), matching: find.byType(Container))
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
    });
  });
}
