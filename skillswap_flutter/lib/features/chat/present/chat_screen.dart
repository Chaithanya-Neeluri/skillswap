import 'dart:async';
import 'package:flutter/material.dart';
import '../data/chat_service.dart';
import 'widgets/chat_input_field.dart';
import 'widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _service = ChatService();
  final ScrollController _scrollCtrl = ScrollController();

  String _conversationId = '';
  String _otherUid = '';
  String _otherName = '';

  StreamSubscription? _msgSub;
  StreamSubscription? _typingSub;

  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _otherTyping = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arg != null) {
      _otherUid = arg['otherUid'] ?? '';
      _otherName = arg['otherName'] ?? '';
      _initConversation();
    }
  }

  Future<void> _initConversation() async {
    setState(() => _loading = true);
    try {
      // Ensure the conversation exists
      final convId = await _service.ensureConversation(_otherUid, _otherName);
      _conversationId = convId;

      // Fetch past messages
      final msgs = await _service.fetchMessages(convId);
      setState(() {
        _messages = msgs;
        _loading = false;
      });

      // Listen to new messages
      _msgSub = _service.messagesStreamFor(convId).listen((msg) {
        setState(() {
          _messages.add(msg);
        });
        _scrollToBottom();
      });

      // Listen to typing events
      _typingSub = _service.typingStreamFor(convId).listen((typing) {
        setState(() => _otherTyping = typing);
      });

      // Mark conversation as read
      _service.markConversationRead(convId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _onSend(String text) async {
    if (text.trim().isEmpty) return;
    await _service.sendMessage(otherUid: _otherUid, text: text, conversationId: _conversationId);
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _typingSub?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_otherName)),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final m = _messages[i];
                      final isMe = m['senderId'] == _service.currentUid;
                      return ChatBubble(
                        text: m['text'] ?? '',
                        isMe: isMe,
                        createdAt: DateTime.tryParse(m['createdAt'] ?? ''),
                        status: m['status'] ?? 'sent',
                      );
                    },
                  ),
          ),
          if (_otherTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$_otherName is typing...',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
                ),
              ),
            ),
          ChatInputField(
            onChanged: (text) => _service.setTyping(_otherUid, text.trim().isNotEmpty),
            onSend: _onSend,
          ),
        ],
      ),
    );
  }
}
