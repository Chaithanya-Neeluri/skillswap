import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_button.dart';

class ChatInputField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSend;

  const ChatInputField({super.key, required this.onChanged, required this.onSend});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _ctrl = TextEditingController();
  bool _isTyping = false;

  void _handleSend() {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) return;
    widget.onSend(txt);
    _ctrl.clear();
    _handleTyping('');
    setState(() => _isTyping = false);
  }

  void _handleTyping(String t) {
    widget.onChanged(t);
    setState(() => _isTyping = t.trim().isNotEmpty);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                onChanged: _handleTyping,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _handleSend,
              icon: const Icon(Icons.send),
              color: Theme.of(context).primaryColor,
            )
          ],
        ),
      ),
    );
  }
}
