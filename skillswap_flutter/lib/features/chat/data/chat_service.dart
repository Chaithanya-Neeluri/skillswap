import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// ChatService - Socket.IO + HTTP hybrid client for Express backend.
/// - Socket events: connect, receiveMessage, typing
/// - HTTP endpoints used as fallback for fetching conversations/messages and ensuring conversation
///
/// NOTE:
/// - Replace BASE_URL with your backend URL.
/// - Your backend should accept Authorization: Bearer <jwt> for protected endpoints.
class ChatService {
  static const String BASE_URL = 'https://your-express-backend.com/api/chat'; // <-- change
  static const String SOCKET_URL = 'https://your-express-backend.com'; // <-- change (no /api)
  IO.Socket? _socket;

  final StreamController<Map<String, dynamic>> _incomingController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _typingController = StreamController.broadcast();

  Stream<Map<String, dynamic>> get incomingMessages => _incomingController.stream;
  Stream<Map<String, dynamic>> get typingEvents => _typingController.stream;

  String? _jwt;
  String? _currentUidCache;

  // Call this on app start / after login to initialize socket connection.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _jwt = prefs.getString('jwt');
    _currentUidCache = prefs.getString('uid'); // if you store uid on login
    _initSocket();
  }

  String get currentUid {
    if (_currentUidCache != null) return _currentUidCache!;
    throw Exception('currentUid not found. Ensure ChatService.init() was called after login.');
  }

  // Helper: deterministic convo id
  String conversationIdFor(String otherUid) {
    final me = currentUid;
    return (me.compareTo(otherUid) < 0) ? '${me}_$otherUid' : '${otherUid}_$me';
  }

  // Initialize Socket.IO connection
  void _initSocket() {
    if (_socket != null && _socket!.connected) return;
    if (_jwt == null) return;

    _socket = IO.io(
      SOCKET_URL,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $_jwt'})
          .build(),
    );

    _socket!.onConnect((_) {
      // connected
      // print('Socket connected: ${_socket!.id}');
    });

    _socket!.on('receiveMessage', (data) {
      // forward to stream
      if (data is String) {
        try {
          final parsed = jsonDecode(data) as Map<String, dynamic>;
          _incomingController.add(parsed);
        } catch (_) {}
      } else if (data is Map) {
        _incomingController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('userTyping', (data) {
      if (data is Map) _typingController.add(Map<String, dynamic>.from(data));
    });

    _socket!.onDisconnect((_) {
      // print('Socket disconnected');
    });
  }

  // Disconnect and cleanup
  void dispose() {
    _socket?.disconnect();
    _incomingController.close();
    _typingController.close();
  }

  // Ensure conversation exists via HTTP (creates doc in DB) and returns conversationId
  Future<String> ensureConversation(String otherUid, String otherName) async {
    final token = await _getJwt();
    final me = currentUid;
    final convoId = conversationIdFor(otherUid);

    final res = await http.post(
      Uri.parse('$BASE_URL/ensure'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'conversationId': convoId, 'members': [me, otherUid], 'memberNames': {me: 'You', otherUid: otherName}}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      // join socket room for realtime
      _socket?.emit('joinRoom', convoId);
      return convoId;
    } else {
      throw Exception('Failed to ensure conversation: ${res.body}');
    }
  }

  // Fetch list of conversations (HTTP)
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final token = await _getJwt();
    final res = await http.get(
      Uri.parse('$BASE_URL/conversations'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as List;
      return body.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Failed to fetch conversations: ${res.body}');
    }
  }

  // Fetch messages for a conversation (HTTP fallback)
  Future<List<Map<String, dynamic>>> fetchMessages(String conversationId) async {
    final token = await _getJwt();
    final res = await http.get(
      Uri.parse('$BASE_URL/messages/$conversationId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as List;
      return body.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Failed to fetch messages: ${res.body}');
    }
  }

  // Send message: emits socket event if connected, else HTTP POST
  Future<void> sendMessage({required String otherUid, required String text, String? conversationId}) async {
    final convId = conversationId ?? conversationIdFor(otherUid);
    final payload = {
      'roomId': convId,
      'senderId': currentUid,
      'receiverId': otherUid,
      'text': text,
      'createdAt': DateTime.now().toIso8601String(),
    };

    if (_socket != null && _socket!.connected) {
      _socket!.emit('sendMessage', payload);
    } else {
      // fallback HTTP
      final token = await _getJwt();
      final res = await http.post(
        Uri.parse('$BASE_URL/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      if (res.statusCode != 200) {
        throw Exception('Failed to send message via HTTP: ${res.body}');
      }
    }
  }

  // Stream of incoming messages filtered by conversationId (client-side filter)
  Stream<Map<String, dynamic>> messagesStreamFor(String conversationId) {
    return incomingMessages.where((msg) {
      final room = msg['roomId'] ?? msg['conversationId'] ?? '';
      return room == conversationId;
    });
  }

  // Typing indicator: emits socket event
  void setTyping(String otherUid, bool isTyping) {
    final convId = conversationIdFor(otherUid);
    if (_socket != null && _socket!.connected) {
      _socket!.emit('typing', {'roomId': convId, 'userId': currentUid, 'typing': isTyping});
    } else {
      // Optionally call HTTP endpoint to set typing presence
    }
  }

  // Listen typing events for a conversation (client-side filter)
  Stream<bool> typingStreamFor(String conversationId) {
    return typingEvents.map((evt) {
      final room = evt['roomId'] ?? '';
      final userId = evt['userId'] ?? '';
      final typing = evt['typing'] ?? false;
      if (room == conversationId && userId != currentUid) return typing as bool;
      return false;
    });
  }

  // Mark conversation read (HTTP)
  Future<void> markConversationRead(String conversationId) async {
    final token = await _getJwt();
    final res = await http.post(
      Uri.parse('$BASE_URL/mark-read'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'conversationId': conversationId, 'userId': currentUid}),
    );
    if (res.statusCode != 200) {
      // optional: ignore
    }
  }

  // Internal helper to get JWT
  Future<String> _getJwt() async {
    if (_jwt != null) return _jwt!;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    if (token == null) throw Exception('JWT token not found in storage');
    _jwt = token;
    return token;
  }
}
