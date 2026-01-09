import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/app_router.dart';
import 'package:sous_chef/models/chat.dart';
import 'package:sous_chef/models/message.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/screens/allChats_screen.dart';
import 'package:sous_chef/screens/chat_screen.dart';
import 'package:sous_chef/themes/light_mode.dart';
import 'package:sous_chef/themes/theme_provider.dart';

/// Mock classes
class MockAuthProvider extends Mock implements AuthProvider {}

class MockChatProvider extends Mock implements ChatProvider {}

class MockUserProvider extends Mock implements UserProvider {}

class MockThemeProvider extends Mock implements ThemeProvider {}

/// Fake BuildContext for mocktail
class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  late MockAuthProvider mockAuthProvider;
  late MockChatProvider mockChatProvider;
  late MockUserProvider mockUserProvider;
  late MockThemeProvider mockThemeProvider;

  // Test data
  late User mockCurrentUser;
  late User mockOtherUser;
  late Chat mockChat;
  late List<ChatInfo> mockChatInfoList;
  late List<Message> mockMessages;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockChatProvider = MockChatProvider();
    mockUserProvider = MockUserProvider();
    mockThemeProvider = MockThemeProvider();

    // Create mock current user
    mockCurrentUser = User(
      id: 'current-user-123',
      email: 'current@example.com',
      username: 'currentuser',
      name: 'Current',
      surname: 'User',
      phone: '1234567890',
      savedAddress: '123 Test Street',
      latitude: 45.4642,
      longitude: 9.1900,
    );

    // Create mock other user (chat partner)
    mockOtherUser = User(
      id: 'other-user-456',
      email: 'other@example.com',
      username: 'otheruser',
      name: 'Other',
      surname: 'User',
      phone: '0987654321',
      savedAddress: '456 Other Street',
      latitude: 45.4650,
      longitude: 9.1850,
    );

    // Create mock chat
    mockChat = Chat(
      id: 'chat-123',
      user1Id: 'current-user-123',
      user2Id: 'other-user-456',
      lastMessage: 'Hello, how are you?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 1,
    );

    // Create ChatInfo list
    mockChatInfoList = [
      ChatInfo(
        chat: mockChat,
        otherUser: mockOtherUser,
        restaurantImageUrl: null,
        unreadCount: 1,
      ),
    ];

    // Create mock messages
    mockMessages = [
      Message(
        id: 'msg-1',
        message: 'Hi there!',
        senderId: 'other-user-456',
        receiverId: 'current-user-123',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isRead: true,
      ),
      Message(
        id: 'msg-2',
        message: 'Hello, how are you?',
        senderId: 'other-user-456',
        receiverId: 'current-user-123',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
    ];

    // === AuthProvider stubs ===
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.isAuthenticated).thenReturn(true);
    when(() => mockAuthProvider.user).thenReturn(mockCurrentUser);
    when(() => mockAuthProvider.init()).thenAnswer((_) async {});

    // === ChatProvider stubs ===
    when(() => mockChatProvider.isLoading).thenReturn(false);
    when(() => mockChatProvider.errorMessage).thenReturn(null);
    when(() => mockChatProvider.chats).thenReturn(mockChatInfoList);
    when(() => mockChatProvider.totalUnreadCount).thenReturn(1);
    when(() => mockChatProvider.hasUnreadMessages).thenReturn(true);
    when(() => mockChatProvider.setCurrentUserId(any())).thenReturn(null);
    when(() => mockChatProvider.startListeningToChats()).thenReturn(null);
    when(() => mockChatProvider.stopListeningToChats()).thenReturn(null);
    when(() => mockChatProvider.loadUserChats()).thenAnswer((_) async {});
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
    when(
      () => mockChatProvider.getMessagesStream(any()),
    ).thenAnswer((_) => Stream.value(mockMessages));

    // === UserProvider stubs ===
    when(() => mockUserProvider.userData).thenReturn(mockCurrentUser);
    when(() => mockUserProvider.isLoading).thenReturn(false);
    when(() => mockUserProvider.fetchUserData()).thenAnswer((_) async {});

    // === ThemeProvider stubs ===
    when(() => mockThemeProvider.themeData).thenReturn(lightMode);
    when(() => mockThemeProvider.isDarkMode).thenReturn(false);
  });

  Widget buildAllChatsScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
        Provider<AppRouter>(create: (_) => AppRouter()),
      ],
      child: Consumer<AppRouter>(
        builder: (context, router, child) {
          return MaterialApp(
            theme: lightMode,
            home: const AllChatsScreen(),
            onGenerateRoute: router.onGenerateRoute,
          );
        },
      ),
    );
  }

  Widget buildChatScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
        Provider<AppRouter>(create: (_) => AppRouter()),
      ],
      child: MaterialApp(
        theme: lightMode,
        home: ChatScreen(
          chatId: 'chat-123',
          otherUserName: 'otheruser',
          otherUserId: 'other-user-456',
        ),
      ),
    );
  }

  group('Chat Flow', () {
    testWidgets('should display AllChatsScreen with chat list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAllChatsScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify AllChatsScreen is displayed
      expect(find.byType(AllChatsScreen), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);

      // Verify chat list item is displayed
      expect(find.text('otheruser'), findsOneWidget);
      expect(find.text('Hello, how are you?'), findsOneWidget);
    });

    testWidgets('should display unread message indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAllChatsScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify unread count badge is displayed
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should navigate to ChatScreen when tapping on a chat', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAllChatsScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Find and tap on the chat item
      final chatItem = find.text('otheruser');
      expect(chatItem, findsOneWidget);

      await tester.tap(chatItem);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Should navigate to ChatScreen
      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('should display ChatScreen with message input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildChatScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify ChatScreen is displayed
      expect(find.byType(ChatScreen), findsOneWidget);

      // Verify message input field exists
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Write a message...'), findsOneWidget);

      // Verify send button exists
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('should display existing messages in chat', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildChatScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify messages are displayed
      expect(find.text('Hi there!'), findsOneWidget);
      expect(find.text('Hello, how are you?'), findsOneWidget);
    });

    testWidgets('should allow typing a message', (WidgetTester tester) async {
      await tester.pumpWidget(buildChatScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Find the message input field
      final messageInput = find.byType(TextField);
      expect(messageInput, findsOneWidget);

      // Type a message
      await tester.enterText(messageInput, 'Hello, this is a test message!');
      await tester.pump(const Duration(milliseconds: 300));

      // Verify the text is entered
      expect(find.text('Hello, this is a test message!'), findsOneWidget);
    });

    testWidgets('should call sendMessage when tapping send button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildChatScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Type a message
      final messageInput = find.byType(TextField);
      await tester.enterText(messageInput, 'Test message to send');
      await tester.pump(const Duration(milliseconds: 300));

      // Tap send button
      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);

      await tester.tap(sendButton);
      await tester.pump(const Duration(milliseconds: 500));

      // Verify sendMessage was called
      verify(
        () => mockChatProvider.sendMessage(
          chatId: 'chat-123',
          receiverId: 'other-user-456',
          message: 'Test message to send',
        ),
      ).called(1);
    });

    testWidgets('should clear message input after sending', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildChatScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Type a message
      final messageInput = find.byType(TextField);
      await tester.enterText(messageInput, 'Message to be cleared');
      await tester.pump(const Duration(milliseconds: 300));

      // Verify message is entered
      expect(find.text('Message to be cleared'), findsOneWidget);

      // Tap send button
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(const Duration(milliseconds: 500));

      // Message input should be cleared (only placeholder visible)
      expect(find.text('Message to be cleared'), findsNothing);
    });

    testWidgets('should not send empty message', (WidgetTester tester) async {
      await tester.pumpWidget(buildChatScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap send button without entering a message
      final sendButton = find.byIcon(Icons.send);
      await tester.tap(sendButton);
      await tester.pump(const Duration(milliseconds: 500));

      // Verify sendMessage was NOT called
      verifyNever(
        () => mockChatProvider.sendMessage(
          chatId: any(named: 'chatId'),
          receiverId: any(named: 'receiverId'),
          message: any(named: 'message'),
        ),
      );
    });

    testWidgets('should mark messages as read when opening chat', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildChatScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify markMessagesAsRead was called
      verify(() => mockChatProvider.markMessagesAsRead('chat-123')).called(1);
    });

    testWidgets('should display empty state when no chats', (
      WidgetTester tester,
    ) async {
      // Set up empty chat list
      when(() => mockChatProvider.chats).thenReturn([]);

      await tester.pumpWidget(buildAllChatsScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify empty state message
      expect(find.text('No chats available'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsWidgets);
    });
  });
}
