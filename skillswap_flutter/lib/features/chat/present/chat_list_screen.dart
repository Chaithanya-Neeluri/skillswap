import 'package:flutter/material.dart';
import '../data/chat_service.dart';
import 'widgets/chat_user_tile.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/newChat'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _chatService.fetchConversations(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final list = snap.data ?? [];
          if (list.isEmpty) return const Center(child: Text('No conversations yet'));
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 0.5),
            itemBuilder: (context, i) {
              final convo = list[i];
              // expected shape: { conversationId, otherUid, otherName, lastMessage, lastAt, unreadCount }
              return ChatUserTile(
                conversationId: convo['conversationId'] ?? convo['id'] ?? '',
                otherUid: convo['otherUid'] ?? '',
                otherName: convo['otherName'] ?? 'Unknown',
                lastMessage: convo['lastMessage'] ?? '',
                lastAt: convo['lastAt'] != null ? DateTime.parse(convo['lastAt']) : null,
                unreadCount: (convo['unreadCount'] ?? 0) as int,
                onTap: () {
                  Navigator.pushNamed(context, '/chatRoom', arguments: {
                    'conversationId': convo['conversationId'] ?? convo['id'],
                    'otherUid': convo['otherUid'],
                    'otherName': convo['otherName'],
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
