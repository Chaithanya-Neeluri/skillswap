// video_call_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../data/video_call_service.dart';
import 'widgets/video_tile.dart';
import 'widgets/call_controls.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final VideoCallService _service = VideoCallService();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  bool _muted = false;
  StreamSubscription? _dummySub;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _service.onLocalStream = (stream) {
      _localRenderer.srcObject = stream;
      setState(() {});
    };
    _service.onAddRemoteStream = (peerId, stream) {
      final r = RTCVideoRenderer();
      r.initialize().then((_) {
        r.srcObject = stream;
        setState(() => _remoteRenderers[peerId] = r);
      });
    };
    _service.onCallEnded = () {
      if (mounted) Navigator.pop(context);
    };
    _service.init();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
  }

  @override
  void dispose() {
    _localRenderer.srcObject = null;
    _localRenderer.dispose();
    for (var r in _remoteRenderers.values) {
      r.srcObject = null;
      r.dispose();
    }
    _service.endCall();
    _dummySub?.cancel();
    super.dispose();
  }

  // toggle mute
  Future<void> _toggleAudio() async {
    await _service.toggleMuteAudio();
    setState(() => _muted = !_muted);
  }

  Future<void> _switchCamera() async {
    await _service.switchCamera();
  }

  Future<void> _endCall() async {
    await _service.endCall();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final remotes = _remoteRenderers.values.toList();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote grid or single remote
            Positioned.fill(
              child: remotes.isEmpty
                  ? Center(child: Text('Waiting for peer...', style: TextStyle(color: Colors.white70)))
                  : GridView.count(
                      crossAxisCount: remotes.length > 1 ? 2 : 1,
                      children: remotes
                          .map((r) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: VideoTile(renderer: r, label: 'Peer', isLocal: false),
                              ))
                          .toList(),
                    ),
            ),

            // Local small preview
            Positioned(
              right: 12,
              top: 12,
              width: 140,
              height: 200,
              child: _localRenderer.srcObject == null
                  ? Container(color: Colors.grey[900], child: const Center(child: Text('No camera')))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: RTCVideoView(_localRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
                    ),
            ),

            // Controls
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: CallControls(
                muted: _muted,
                onToggleAudio: _toggleAudio,
                onSwitchCamera: _switchCamera,
                onEndCall: _endCall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
