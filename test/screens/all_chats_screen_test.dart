import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/chat.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/screens/allChats_screen.dart';
import 'package:sous_chef/screens/chat_screen.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockChatProvider mockChatProvider;

  // Sample test user
  final testUser = User(
    id: 'test-user-id',
    email: 'test@example.com',
    username: 'testuser',
    name: 'Test',
    surname: 'User',
    phone: '1234567890',
    restaurantId: null,
  );

  // Sample other users for chats
  final otherUser1 = User(
    id: 'other-user-1',
    email: 'other1@example.com',
    username: 'otheruser1',
    name: 'Other',
    surname: 'User1',
    phone: '1111111111',
    restaurantId: 'restaurant-1',
  );

  final otherUser2 = User(
    id: 'other-user-2',
    email: 'other2@example.com',
    username: 'otheruser2',
    name: 'Other',
    surname: 'User2',
    phone: '2222222222',
    restaurantId: 'restaurant-2',
  );

  // Sample chats
  final testChat1 = Chat(
    id: 'chat-1',
    user1Id: 'test-user-id',
    user2Id: 'other-user-1',
    lastMessage: 'Hello, how are you?',
    lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
    unreadCount: 2,
  );

  final testChat2 = Chat(
    id: 'chat-2',
    user1Id: 'test-user-id',
    user2Id: 'other-user-2',
    lastMessage: 'Thanks for your order!',
    lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 0,
  );

  // Sample ChatInfo list
  late List<ChatInfo> testChatInfoList;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockChatProvider = MockChatProvider();

    // Initialize ChatInfo list
    testChatInfoList = [
      ChatInfo(
        chat: testChat1,
        otherUser: otherUser1,
        restaurantImageUrl: 'https://example.com/image1.jpg',
        unreadCount: 2,
      ),
      ChatInfo(
        chat: testChat2,
        otherUser: otherUser2,
        restaurantImageUrl: null,
        unreadCount: 0,
      ),
    ];

    // Stub default values for AuthProvider
    when(() => mockAuthProvider.user).thenReturn(testUser);
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
    when(() => mockAuthProvider.init()).thenAnswer((_) async {});

    // Stub default values for ChatProvider
    when(() => mockChatProvider.isLoading).thenReturn(false);
    when(() => mockChatProvider.errorMessage).thenReturn(null);
    when(() => mockChatProvider.chats).thenReturn(testChatInfoList);
    when(() => mockChatProvider.totalUnreadCount).thenReturn(2);
    when(() => mockChatProvider.setCurrentUserId(any())).thenReturn(null);
    when(() => mockChatProvider.startListeningToChats()).thenReturn(null);
    when(() => mockChatProvider.stopListeningToChats()).thenReturn(null);
    when(() => mockChatProvider.loadUserChats()).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValues();
  });

  // Helper to ignore overflow errors during tests
  void ignoreOverflowErrors(
    FlutterErrorDetails details, {
    bool forceReport = false,
  }) {
    bool ifIsOverflowError = false;
    final exception = details.exception;
    if (exception is FlutterError) {
      ifIsOverflowError = exception.diagnostics.any(
        (e) => e.value.toString().contains('overflowed'),
      );
    }
    if (!ifIsOverflowError) {
      FlutterError.presentError(details);
    }
  }

  group('AllChatsScreen', () {
    // =========================================================================
    // RENDERING TESTS
    // =========================================================================

    group('Rendering', () {
      testWidgets('renders app bar with title "Chat"', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Chat'), findsOneWidget);
      });

      testWidgets('app bar is centered', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.centerTitle, isTrue);
      });

      testWidgets('displays chat list items', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(ListTile), findsNWidgets(2));
      });

      testWidgets('displays usernames in chat list', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('otheruser1'), findsOneWidget);
        expect(find.text('otheruser2'), findsOneWidget);
      });

      testWidgets('displays last messages in chat list', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Hello, how are you?'), findsOneWidget);
        expect(find.text('Thanks for your order!'), findsOneWidget);
      });

      testWidgets('displays CircleAvatar for each chat', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(CircleAvatar), findsNWidgets(2));
      });
    });

    // =========================================================================
    // LOADING STATE TESTS
    // =========================================================================

    group('Loading State', () {
      testWidgets('displays loading indicator when provider is loading', (
        tester,
      ) async {
        when(() => mockChatProvider.isLoading).thenReturn(true);
        when(() => mockChatProvider.chats).thenReturn([]);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();

        FlutterError.onError = originalOnError;

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('hides loading indicator after chats are loaded', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    // =========================================================================
    // EMPTY STATE TESTS
    // =========================================================================

    group('Empty State', () {
      testWidgets('displays empty message when no chats', (tester) async {
        when(() => mockChatProvider.chats).thenReturn([]);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('No chats available'), findsOneWidget);
      });

      testWidgets('displays chat bubble icon when no chats', (tester) async {
        when(() => mockChatProvider.chats).thenReturn([]);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.chat_bubble_outline), findsAtLeastNWidgets(1));
      });
    });

    // =========================================================================
    // ERROR STATE TESTS
    // =========================================================================

    group('Error State', () {
      testWidgets('displays error message when error occurs', (tester) async {
        when(() => mockChatProvider.errorMessage).thenReturn('Network error');
        when(() => mockChatProvider.chats).thenReturn([]);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Network error'), findsOneWidget);
      });

      testWidgets('displays retry button when error occurs', (tester) async {
        when(() => mockChatProvider.errorMessage).thenReturn('Network error');
        when(() => mockChatProvider.chats).thenReturn([]);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Riprova'), findsOneWidget);
      });

      testWidgets('displays error icon when error occurs', (tester) async {
        when(() => mockChatProvider.errorMessage).thenReturn('Network error');
        when(() => mockChatProvider.chats).thenReturn([]);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    // =========================================================================
    // PROVIDER INTERACTION TESTS
    // =========================================================================

    group('Provider Interaction', () {
      testWidgets('calls setCurrentUserId on init', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        verify(() => mockChatProvider.setCurrentUserId(any())).called(1);
      });

      testWidgets('calls startListeningToChats on init', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        verify(() => mockChatProvider.startListeningToChats()).called(1);
      });
    });

    // =========================================================================
    // LAYOUT TESTS - MOBILE
    // =========================================================================

    group('Layout - Mobile (shortestSide < 600)', () {
      const mobileSize = Size(500, 900);

      testWidgets('renders app bar with title on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Chat'), findsOneWidget);
      });

      testWidgets('displays chat list on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(ListTile), findsNWidgets(2));
      });

      testWidgets('uses vertical layout on mobile (no Row)', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Mobile should not have ChatScreen embedded
        expect(find.byType(ChatScreen), findsNothing);
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET VERTICAL
    // =========================================================================

    group('Layout - Tablet Vertical (shortestSide >= 600, portrait)', () {
      const tabletVerticalSize = Size(700, 1000);

      testWidgets('renders app bar with title on tablet vertical', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Chat'), findsOneWidget);
      });

      testWidgets('displays chat list on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(ListTile), findsNWidgets(2));
      });

      testWidgets('uses vertical layout on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Tablet vertical should not have ChatScreen embedded
        expect(find.byType(ChatScreen), findsNothing);
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET HORIZONTAL (SPLIT VIEW)
    // =========================================================================

    group('Layout - Tablet Horizontal (shortestSide >= 600, landscape)', () {
      const tabletHorizontalSize = Size(1024, 700);

      testWidgets('renders app bar with title on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Chat'), findsOneWidget);
      });

      testWidgets('uses Row layout on tablet horizontal (split view)', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Should use Row layout for split view
        expect(find.byType(Row), findsWidgets);
      });

      testWidgets('displays chat list on left side on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AllChatsScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(ListTile), findsNWidgets(2));
      });

      testWidgets(
        'displays placeholder text when no chat selected on tablet horizontal',
        (tester) async {
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          await tester.pumpApp(
            const AllChatsScreen(),
            authProvider: mockAuthProvider,
            chatProvider: mockChatProvider,
            screenSize: tabletHorizontalSize,
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          FlutterError.onError = originalOnError;

          expect(find.text('Click on a chat to view messages'), findsOneWidget);
        },
      );

      testWidgets(
        'displays chat_bubble_outline icon when no chat selected on tablet horizontal',
        (tester) async {
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          await tester.pumpApp(
            const AllChatsScreen(),
            authProvider: mockAuthProvider,
            chatProvider: mockChatProvider,
            screenSize: tabletHorizontalSize,
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          FlutterError.onError = originalOnError;

          expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
        },
      );
    });
  });
}
