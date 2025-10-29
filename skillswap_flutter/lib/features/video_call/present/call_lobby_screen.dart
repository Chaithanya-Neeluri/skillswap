// call_lobby_screen.dart
import 'package:flutter/material.dart';
import '../data/video_call_service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/theme/app_text_styles.dart';

class CallLobbyScreen extends StatefulWidget {
  final String roomId; // e.g., generated per session
  final String displayName;

  const CallLobbyScreen({super.key, required this.roomId, required this.displayName});

  @override
  State<CallLobbyScreen> createState() => _CallLobbyScreenState();
}

class _CallLobbyScreenState extends State<CallLobbyScreen> {
  final VideoCallService _service = VideoCallService();
  bool _joined = false;
  String _log = '';

  @override
  void initState() {
    super.initState();
    _service.onLog = (s) => setState(() => _log = s);
    _service.onCallEnded = () {
      if (mounted) Navigator.pop(context);
    };
    _service.init();
  }

  Future<void> _join() async {
    try {
      await _service.getUserMedia();
      await _service.joinRoom(widget.roomId);
      setState(() => _joined = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Join error: $e')));
    }
  }

  Future<void> _startAndOffer() async {
    try {
      await _service.getUserMedia();
      await _service.joinRoom(widget.roomId);
      await _service.createOffer();
      setState(() => _joined = true);
      // navigate to call screen
      if (mounted) Navigator.pushReplacementNamed(context, '/videoCall', arguments: {'roomId': widget.roomId});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Start error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Lobby')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Room: ${widget.roomId}', style: AppTextStyles.body),
            const SizedBox(height: 12),
            Text('You: ${widget.displayName}', style: AppTextStyles.subheading),
            const SizedBox(height: 24),
            if (!_joined)
              Column(
                children: [
                  CustomButton(text: 'Join (listen)', onPressed: _join),
                  const SizedBox(height: 12),
                  CustomButton(text: 'Start & Offer', onPressed: _startAndOffer),
                ],
              )
            else
              Text('Joined — wait for peers', style: AppTextStyles.caption),
            const Spacer(),
            Text('Log: $_log', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
