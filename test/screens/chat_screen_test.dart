import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/message.dart';
import 'package:sous_chef/models/user.dart';
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

  // Sample messages
  final testMessages = <Message>[
    Message(
      id: 'message-1',
      message: 'Hello!',
      senderId: 'test-user-id',
      receiverId: 'other-user-id',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    Message(
      id: 'message-2',
      message: 'Hi there! How can I help you?',
      senderId: 'other-user-id',
      receiverId: 'test-user-id',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
    ),
    Message(
      id: 'message-3',
      message: 'I would like to place an order',
      senderId: 'test-user-id',
      receiverId: 'other-user-id',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
  ];

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockChatProvider = MockChatProvider();

    // Stub default values for AuthProvider
    when(() => mockAuthProvider.user).thenReturn(testUser);
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
    when(() => mockAuthProvider.init()).thenAnswer((_) async {});

    // Stub default values for ChatProvider
    when(() => mockChatProvider.isLoading).thenReturn(false);
    when(() => mockChatProvider.errorMessage).thenReturn(null);
    when(() => mockChatProvider.chats).thenReturn([]);
    when(() => mockChatProvider.totalUnreadCount).thenReturn(0);
    when(
      () => mockChatProvider.getMessagesStream(any()),
    ).thenAnswer((_) => Stream.value(testMessages));
    when(
      () => mockChatProvider.markMessagesAsRead(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockChatProvider.sendMessage(
        chatId: any(named: 'chatId'),
        receiverId: any(named: 'receiverId'),
        message: any(named: 'message'),
      ),
    ).thenAnswer((_) async {});
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

  group('ChatScreen', () {
    // =========================================================================
    // RENDERING TESTS
    // =========================================================================

    group('Rendering', () {
      testWidgets('renders app bar with other user name', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Restaurant Name'), findsOneWidget);
      });

      testWidgets('displays CircleAvatar in app bar', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(CircleAvatar), findsAtLeastNWidgets(1));
      });

      testWidgets('displays message input field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('displays send button', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.send), findsOneWidget);
      });

      testWidgets('displays placeholder text in input field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Write a message...'), findsOneWidget);
      });
    });

    // =========================================================================
    // LOADING STATE TESTS
    // =========================================================================

    group('Loading State', () {
      testWidgets('shows StreamBuilder widget for messages', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();

        FlutterError.onError = originalOnError;

        expect(find.byType(StreamBuilder<List<Message>>), findsOneWidget);
      });
    });

    // =========================================================================
    // EMPTY STATE TESTS
    // =========================================================================

    group('Empty State', () {
      testWidgets('displays empty message when no messages', (tester) async {
        when(
          () => mockChatProvider.getMessagesStream(any()),
        ).thenAnswer((_) => Stream.value([]));

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(
          find.text('No messages. Start the conversation!'),
          findsOneWidget,
        );
      });
    });

    // =========================================================================
    // MESSAGES DISPLAY TESTS
    // =========================================================================

    group('Messages Display', () {
      testWidgets('displays message texts', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Hello!'), findsOneWidget);
        expect(find.text('Hi there! How can I help you?'), findsOneWidget);
        expect(find.text('I would like to place an order'), findsOneWidget);
      });

      testWidgets('displays messages in ListView', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(ListView), findsOneWidget);
      });
    });

    // =========================================================================
    // EMBEDDED MODE TESTS (for tablet horizontal)
    // =========================================================================

    group('Embedded Mode', () {
      testWidgets('hides app bar when isEmbedded is true', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
            isEmbedded: true,
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Should not have AppBar when embedded
        expect(find.byType(AppBar), findsNothing);
      });

      testWidgets('shows app bar when isEmbedded is false', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
            isEmbedded: false,
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('displays message input when embedded', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
            isEmbedded: true,
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.send), findsOneWidget);
      });
    });

    // =========================================================================
    // PROVIDER INTERACTION TESTS
    // =========================================================================

    group('Provider Interaction', () {
      testWidgets('calls markMessagesAsRead on init', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        verify(() => mockChatProvider.markMessagesAsRead('chat-123')).called(1);
      });

      testWidgets('calls getMessagesStream with correct chatId', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        verify(() => mockChatProvider.getMessagesStream('chat-123')).called(1);
      });
    });

    // =========================================================================
    // LAYOUT TESTS - MOBILE
    // =========================================================================

    group('Layout - Mobile (shortestSide < 600)', () {
      const mobileSize = Size(500, 900);

      testWidgets('renders app bar with user name on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Restaurant Name'), findsOneWidget);
      });

      testWidgets('displays message input on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('displays messages on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Hello!'), findsOneWidget);
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET VERTICAL
    // =========================================================================

    group('Layout - Tablet Vertical (shortestSide >= 600, portrait)', () {
      const tabletVerticalSize = Size(700, 1000);

      testWidgets('renders app bar with user name on tablet vertical', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Restaurant Name'), findsOneWidget);
      });

      testWidgets('displays message input on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(TextField), findsOneWidget);
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET HORIZONTAL (EMBEDDED)
    // =========================================================================

    group('Layout - Tablet Horizontal (embedded in split view)', () {
      const tabletHorizontalSize = Size(1024, 700);

      testWidgets('hides app bar when embedded on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
            isEmbedded: true,
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(AppBar), findsNothing);
      });

      testWidgets('displays message input when embedded on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
            isEmbedded: true,
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.send), findsOneWidget);
      });

      testWidgets('displays messages when embedded on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const ChatScreen(
            chatId: 'chat-123',
            otherUserName: 'Restaurant Name',
            otherUserId: 'other-user-id',
            isEmbedded: true,
          ),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Hello!'), findsOneWidget);
      });
    });
  });
}
