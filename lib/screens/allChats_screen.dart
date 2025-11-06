import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/screens/chat_screen.dart';
import 'package:intl/intl.dart';

class AllChatsScreen extends StatefulWidget {
  const AllChatsScreen({super.key});

  @override
  State<AllChatsScreen> createState() => _AllChatsScreenState();
}

class _AllChatsScreenState extends State<AllChatsScreen> {
  late ChatProvider _chatProvider;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    // Start listening to real-time chat updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider = Provider.of<AuthProvider>(context, listen: false);
      _chatProvider = Provider.of<ChatProvider>(context, listen: false);

      debugPrint('AllChatsScreen: Current user ID = ${_authProvider.user?.id}');

      // Set the current user ID from AuthProvider
      _chatProvider.setCurrentUserId(_authProvider.user?.id);

      // Start listening to chats
      _chatProvider.startListeningToChats();
    });
  }

  @override
  void dispose() {
    // Use saved provider reference instead of doing Provider.of in dispose
    _chatProvider.stopListeningToChats();
    super.dispose();
  }

  // Function to format time
  String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Ieri';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat.EEEE('it').format(dateTime);
    } else {
      // Older - show date
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }

  // Funzione per estrarre le iniziali da un nome
  String getInitials(String name) {
    if (name.isEmpty) return '';
    List<String> parts = name.trim().split(' ');
    String initials = '';
    if (parts.isNotEmpty) {
      initials += parts[0][0];
    }
    if (parts.length > 1) {
      initials += parts[1][0];
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat'), centerTitle: true),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    chatProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => chatProvider.loadUserChats(),
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          if (chatProvider.chats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No chats available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chatProvider.chats.length,
            itemBuilder: (BuildContext context, int index) {
              final chatInfo = chatProvider.chats[index];
              final otherUser = chatInfo.otherUser;
              final chat = chatInfo.chat;
              final unreadCount = chatInfo.unreadCount;
              final restaurantImageUrl = chatInfo.restaurantImageUrl;

              // Use username or fallback to name if username is not available
              final displayName =
                  otherUser?.username ??
                  '${otherUser?.name ?? ''} ${otherUser?.surname ?? ''}'.trim();

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage:
                          restaurantImageUrl != null &&
                                  restaurantImageUrl.isNotEmpty
                              ? NetworkImage(restaurantImageUrl)
                              : null,
                      child:
                          restaurantImageUrl == null ||
                                  restaurantImageUrl.isEmpty
                              ? Text(
                                getInitials(displayName),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                              : null,
                    ),
                    title: Text(
                      displayName.isNotEmpty
                          ? displayName
                          : 'Utente Sconosciuto',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      chat.lastMessage ?? 'No messages',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatTime(chat.lastMessageTime),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                unreadCount > 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    onTap: () {
                      debugPrint('Navigating to chat: ${chat.id}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatScreen(
                                chatId: chat.id,
                                otherUserName:
                                    displayName.isNotEmpty
                                        ? displayName
                                        : 'Utente Sconosciuto',
                                otherUserImageUrl: restaurantImageUrl,
                              ),
                        ),
                      );
                    },
                  ),
                  if (index < chatProvider.chats.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 0.2,
                      indent: 88,
                      endIndent: 16,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
