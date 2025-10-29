// video_call_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

/// VideoCallService
/// - Manages WebRTC PeerConnection lifecycle
/// - Uses Socket.IO for signaling (offer/answer/ice)
/// - Provides simple API: init(), joinRoom(), createOffer(), endCall()
class VideoCallService {
  static const String SOCKET_URL = 'https://your-express-backend.com'; // <-- change
  IO.Socket? _socket;

  // WebRTC
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  final Map<String, MediaStream> remoteStreams = {}; // keyed by peerId
  final Map<String, RTCRtpSender> _senders = {};

  // callbacks for UI
  void Function(MediaStream local)? onLocalStream;
  void Function(String peerId, MediaStream remote)? onAddRemoteStream;
  void Function()? onCallEnded;
  void Function(String info)? onLog;

  String? _roomId;
  String? _uid;
  bool _inited = false;

  // STUN/TURN config (production: put TURN creds on server)
  static const Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      // add TURN servers here for production
      // {'urls': 'turn:turn.yourdomain.com:3478', 'username': 'user', 'credential': 'pass'}
    ]
  };

  /// Initialize service (call after login, once)
  Future<void> init() async {
    if (_inited) return;
    final prefs = await SharedPreferences.getInstance();
    _uid = prefs.getString('uid') ?? prefs.getString('userId') ?? 'anonymous';
    _initSocket();
    _inited = true;
  }

  void _initSocket() {
    try {
      if (_socket != null && _socket!.connected) return;

      _socket = IO.io(
        SOCKET_URL,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build(),
      );

      _socket!.onConnect((_) => _log('socket connected: ${_socket!.id}'));
      _socket!.on('offer', (data) => _onOffer(data));
      _socket!.on('answer', (data) => _onAnswer(data));
      _socket!.on('ice-candidate', (data) => _onIceCandidate(data));
      _socket!.on('peer-left', (data) => _onPeerLeft(data));
      _socket!.onDisconnect((_) => _log('socket disconnected'));
    } catch (e) {
      _log('socket init error: $e');
    }
  }

  void _log(String s) {
    // safe logging callback
    try {
      if (onLog != null) onLog!(s);
    } catch (_) {}
  }

  /// Acquire local media (camera/microphone)
  Future<MediaStream> getUserMedia({bool audio = true, bool video = true}) async {
    final Map<String, dynamic> constraints = {
      'audio': audio,
      'video': video
          ? {
              'facingMode': 'user',
              'width': {'ideal': 1280},
              'height': {'ideal': 720},
            }
          : false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    onLocalStream?.call(_localStream!);
    return _localStream!;
  }

  /// Join a room (prepare PeerConnection and join signaling room)
  Future<void> joinRoom(String roomId) async {
    await init();
    _roomId = roomId;

    // create peer connection
    _pc = await createPeerConnection(_iceServers, {});

    // ensure local stream present
    if (_localStream == null) {
      await getUserMedia();
    }

    // add local tracks and keep senders
    _localStream!.getTracks().forEach((t) async {
      final sender = _pc!.addTrack(t, _localStream!);
      // ignore: unnecessary_null_comparison
      if (sender != null) _senders[t.id!] = await sender;
    });

    // handle remote track events
    _pc!.onTrack = (RTCTrackEvent event) {
      try {
        if (event.streams.isNotEmpty) {
          final remote = event.streams[0];
          final peerId = event.track?.id ?? 'peer';
          remoteStreams[peerId] = remote;
          onAddRemoteStream?.call(peerId, remote);
        }
      } catch (e) {
        _log('onTrack error: $e');
      }
    };

    // ICE candidates from local -> send over socket
    _pc!.onIceCandidate = (RTCIceCandidate? candidate) {
      try {
        if (candidate == null) return;
        _socket?.emit('ice-candidate', {
          'roomId': roomId,
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex
          },
          'from': _uid
        });
      } catch (e) {
        _log('onIceCandidate emit error: $e');
      }
    };

    // join signaling room on server
    _socket?.emit('join-call', {'roomId': roomId, 'userId': _uid});
    _log('joined signaling room: $roomId');
  }

  /// Create an offer (caller)
  Future<void> createOffer() async {
    if (_pc == null) throw Exception('PeerConnection not initialized');
    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);
    _socket?.emit('offer', {
      'roomId': _roomId,
      'sdp': offer.sdp,
      'type': offer.type,
      'from': _uid,
    });
    _log('offer created & sent');
  }

  /// Handler when receiving an offer (callee)
  Future<void> _onOffer(dynamic data) async {
    try {
      final sdp = data['sdp'] as String?;
      final type = data['type'] as String?;
      final from = data['from'] as String?;
      _log('offer received from $from');

      // ensure pc exists
      if (_pc == null) {
        _pc = await createPeerConnection(_iceServers, {});
        // add local stream tracks
        if (_localStream == null) await getUserMedia();
        _localStream!.getTracks().forEach((t) => _pc!.addTrack(t, _localStream!));

        _pc!.onTrack = (RTCTrackEvent ev) {
          try {
            if (ev.streams.isNotEmpty) {
              onAddRemoteStream?.call(ev.track?.id ?? 'peer', ev.streams[0]);
            }
          } catch (e) {
            _log('onTrack error: $e');
          }
        };

        _pc!.onIceCandidate = (RTCIceCandidate? c) {
          try {
            if (c == null) return;
            _socket?.emit('ice-candidate', {
              'roomId': _roomId,
              'candidate': {
                'candidate': c.candidate,
                'sdpMid': c.sdpMid,
                'sdpMLineIndex': c.sdpMLineIndex
              },
              'from': _uid
            });
          } catch (e) {
            _log('onIceCandidate emit error: $e');
          }
        };
      }

      if (sdp == null || type == null) {
        _log('offer data missing sdp/type');
        return;
      }

      final remoteDesc = RTCSessionDescription(sdp, type);
      await _pc!.setRemoteDescription(remoteDesc);

      final answer = await _pc!.createAnswer();
      await _pc!.setLocalDescription(answer);

      _socket?.emit('answer', {
        'roomId': _roomId,
        'sdp': answer.sdp,
        'type': answer.type,
        'from': _uid,
      });
      _log('answer created & sent');
    } catch (e) {
      _log('onOffer error: $e');
    }
  }

  /// Handler for incoming answer (caller side)
  Future<void> _onAnswer(dynamic data) async {
    try {
      final sdp = data['sdp'] as String?;
      final type = data['type'] as String?;
      if (sdp == null || type == null) return;
      final desc = RTCSessionDescription(sdp, type);
      await _pc?.setRemoteDescription(desc);
      _log('answer applied');
    } catch (e) {
      _log('onAnswer error: $e');
    }
  }

  /// Handler for ICE candidates from remote peer
  Future<void> _onIceCandidate(dynamic data) async {
    try {
      final candidate = data['candidate'];
      if (candidate == null) return;
      final c = RTCIceCandidate(candidate['candidate'], candidate['sdpMid'], candidate['sdpMLineIndex']);
      await _pc?.addCandidate(c);
    } catch (e) {
      _log('onIceCandidate error: $e');
    }
  }

  void _onPeerLeft(dynamic data) {
    _log('peer left: $data');
    onCallEnded?.call();
  }

  /// Toggle mute/unmute local audio
  Future<void> toggleMuteAudio() async {
    if (_localStream == null) return;
    for (var t in _localStream!.getAudioTracks()) {
      t.enabled = !t.enabled;
    }
  }

  /// Switch camera (only works if device has switch capability)
  Future<void> switchCamera() async {
    final videoTracks = _localStream?.getVideoTracks();
    if (videoTracks == null || videoTracks.isEmpty) return;
    try {
      final track = videoTracks[0];
      // flutter_webrtc provides Helper.switchCamera
      await Helper.switchCamera(track);
    } catch (e) {
      _log('switchCamera error: $e');
    }
  }

  /// Leave/end call and cleanup local resources
  Future<void> endCall() async {
    try {
      if (_socket != null && _roomId != null) {
        _socket!.emit('leave-call', {'roomId': _roomId, 'userId': _uid});
      }
    } catch (_) {}
    try {
      await _pc?.close();
    } catch (_) {}
    _pc = null;

    try {
      _localStream?.getTracks().forEach((t) => t.stop());
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;

    try {
      for (var s in remoteStreams.values) {
        try {
          s.getTracks().forEach((t) => t.stop());
          s.dispose();
        } catch (_) {}
      }
      remoteStreams.clear();
    } catch (_) {}

    // Disconnect socket optionally (if you want to reuse socket for other calls, skip disconnect)
    try {
      _socket?.disconnect();
      _socket = null;
    } catch (_) {}

    onCallEnded?.call();
  }
}
