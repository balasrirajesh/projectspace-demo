import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:image_picker/image_picker.dart';
import 'dart:io' as dart_io;
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:permission_handler/permission_handler.dart';

/// Roles for the classroom:
/// - Mentor (Alumni/Faculty): Can start sessions, send offers.
/// - Student: Joins sessions, sends answers.
enum ClassroomRole { mentor, student }

class ClassroomService {
  // Singleton pattern for unified signaling
  static final ClassroomService _instance = ClassroomService._internal();
  factory ClassroomService() => _instance;
  ClassroomService._internal();

  io.Socket? _socket;
  String _roomId = '';
  ClassroomRole _role = ClassroomRole.student;

  /// Exposes the current socket ID so the UI can filter out its own entry
  /// from the participants map (avoids ghost self-tile after reconnect).
  String? get mySocketId => _socket?.id;

  // WebRTC core objects
  MediaStream? localStream;
  MediaStream? localScreenStream; // Added for screen sharing
  final Map<String, RTCPeerConnection> peerConnections = {};
  final Map<String, MediaStream> remoteStreams = {};
  final Map<String, MediaStream> remoteScreenStreams = {}; 
  final Map<String, Map<String, String>> participants = {}; 
  final Map<String, List<RTCIceCandidate>> _iceQueues = {}; // Queue for candidates arriving before remote description
  final Set<String> _remoteDescriptionsSet = {}; // Track which peers have had their remote description set

  // Handlers for the UI
  Function(String participantId, MediaStream stream)? onRemoteStreamAdded;
  Function(String participantId)? onRemoteStreamRemoved;
  Function(String from, String text)? onChatMessage;
  Function(String from, bool isRaised)? onHandRaised;
  Function(String mentorId, String userName, {String? role})? onMentorJoined;
  Function(String message)? onError;
  Function()? onConnected;
  Function(List<dynamic> rooms)? onRoomListUpdate;
  Function(Map<String, dynamic> data)? onAnnouncementReceived;
  Function(bool canAccessMic, bool canAccessVideo, bool canShareScreen)? onPermissionUpdate;
  Function(String socketId, bool isSharing)? onRemoteScreenShareUpdated;
  Function()? onParticipantsChanged; // Added to notify UI of participant list changes

  // Robust WebRTC Configuration using STUN & Free TURN for NAT Traversal
  final Map<String, dynamic> _rtcConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun3.l.google.com:19302'},
      {'urls': 'stun:stun4.l.google.com:19302'},
      {'urls': 'stun:global.stun.twilio.com:3478?transport=udp'},
      {
        'urls': [
          'stun:openrelay.metered.ca:80',
          'turn:openrelay.metered.ca:80',
          'turn:openrelay.metered.ca:443?transport=tcp',
          'turn:openrelay.metered.ca:443?transport=udp'
        ],
        'username': 'openrelay',
        'credential': 'openrelay'
      }
    ],
    'sdpSemantics': 'unified-plan',
  };

  void _startHandshakeWatchdog() {
    // Every 10 seconds, check if we have participants without streams
    Future.delayed(const Duration(seconds: 10), () async {
      if (_socket == null || !_socket!.connected) return;

      for (var entry in participants.entries) {
        final id = entry.key;
        if (id == _socket!.id) continue;

        if (!remoteStreams.containsKey(id)) {
          dev.log('🐕 [RTC] Watchdog: No stream for $id (${entry.value['userName']}). Re-initiating offer...');
          await _createOffer(id, participants[_socket!.id]?['userName'] ?? 'User');
        }
      }
      _startHandshakeWatchdog();
    });
  }

  /// Main entry point to join a classroom or the global lobby.
  Future<void> joinRoom({
    required String serverUrl,
    required String roomId,
    required String userName,
    ClassroomRole role = ClassroomRole.student,
    bool useMedia = true,
    bool startWithMedia = true,
  }) async {
    _roomId = roomId;
    _role = role;

    // --- Media Setup ---
    if (useMedia && startWithMedia) {
      try {
        if (!kIsWeb) {
          final camStatus = await Permission.camera.request();
          final micStatus = await Permission.microphone.request();

          if (camStatus != PermissionStatus.granted ||
              micStatus != PermissionStatus.granted) {
            dev.log('❌ [RTC] Permissions denied: Cam=$camStatus, Mic=$micStatus');
            onError?.call('Camera/Microphone permissions are required.');
            return; // Stop if permissions not granted
          }
        }

        localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': {
            'facingMode': 'user',
            'width': 640,
            'height': 480,
          }
        });
        dev.log('📹 [RTC] Local stream initialized for $userName');
      } catch (e) {
        dev.log('❌ [RTC] Media error: $e');
        onError?.call('Could not access camera/microphone.');
      }
    }

    // --- Socket Setup ---
    if (_socket != null && _socket!.connected) {
      _socket!.disconnect();
    }

    dev.log('📡 [SOCKET] Connecting to: $serverUrl/api/socket');
    
    _socket = io.io(serverUrl, io.OptionBuilder()
        .setTransports(['websocket', 'polling']) 
        .setPath('/api/socket')
        .setQuery({'userName': userName})
        .disableAutoConnect()
        .setReconnectionAttempts(15)
        .setReconnectionDelay(2000)
        .build());

    _registerBasicEvents(userName);
    _socket!.connect();
  }

  void _registerBasicEvents(String userName) {
    _socket!.onConnect((_) {
      dev.log('✅ [SOCKET] Connected to signaling server');
      onConnected?.call();
      _startHandshakeWatchdog();
      _socket!.emit('join-room', {
        'roomId': _roomId,
        'role': _role.name,
        'userName': userName,
        'title': _roomId
      });
    });

    _socket!.onDisconnect((_) => dev.log('❌ [SOCKET] Disconnected'));
    _socket!.onConnectError((data) {
      dev.log('⚠️ [SOCKET] Connection Error: $data');
      onError?.call('Could not connect to signaling server. Please check your internet or server status.');
    });
    _socket!.on('connect_timeout', (data) {
      dev.log('⚠️ [SOCKET] Connection Timeout: $data');
      onError?.call('Signaling server connection timed out.');
    });
    _socket!.on('error', (msg) => onError?.call(msg.toString()));

    // --- Signaling Handshake (MESH Logic) ---

    _socket!.on('participant-list', (data) async {
      dev.log('👥 [RTC] participant-list received: $data');
      final Map<dynamic, dynamic> participantMap = data as Map;

      participants.clear();
      participantMap.forEach((id, metadata) {
        final Map<String, String> meta = Map<String, String>.from(
            (metadata as Map).map((key, value) => MapEntry(key.toString(), value.toString())));
        final remoteId = id.toString();
        participants[remoteId] = meta;

        if (remoteId != _socket!.id) {
          final role = meta['role'];
          if (role == 'mentor' || role == 'admin' || role == 'alumni' || role == 'faculty') {
            onMentorJoined?.call(remoteId, meta['userName'] ?? 'Host', role: role);
          }
          // The new joiner (us) ALWAYS creates offers to all existing participants.
          // This is the correct MESH handshake — do NOT use polite-peer socket-ID
          // comparison here, because the alumni's 'participant-joined' handler
          // ALSO creates an offer back to us. Glare is handled in _handleOffer.
          dev.log('📤 [RTC] Creating offer to existing participant $remoteId');
          _createOffer(remoteId, userName);
        }
      });

      onParticipantsChanged?.call();
    });

    _socket!.on('participant-joined', (data) {
      final id = data['socketId'].toString();
      dev.log('👋 [RTC] Participant entered: ${data['userName']} ($id)');

      final Map<String, String> meta = {
        'role': data['role']?.toString() ?? 'student',
        'userName': data['userName']?.toString() ?? 'Anonymous'
      };
      participants[id] = meta;
      onParticipantsChanged?.call();

      if (meta['role'] == 'mentor' || meta['role'] == 'admin' || meta['role'] == 'alumni' || meta['role'] == 'faculty') {
        onMentorJoined?.call(id, meta['userName']!, role: meta['role']);
      }

      // Existing participants ALSO create an offer to the new joiner.
      // This ensures the two-way video flows even if the new joiner's
      // own offer (from participant-list) is delayed or dropped.
      // Glare between the two competing offers is resolved in _handleOffer.
      dev.log('📤 [RTC] Creating offer to new joiner $id');
      _createOffer(id, userName);
    });

    _socket!.on('participant-left', (id) {
      dev.log('🚪 [RTC] Participant left: $id');
      participants.remove(id);
      _removePeer(id);
    });

    // Relay Listeners — all wrapped in try-catch so a WebRTC failure
    // cannot become an unhandled Future rejection that crashes the Dart isolate.
    _socket!.on('offer', (data) async {
      try {
        await _handleOffer(data, userName);
      } catch (e) {
        dev.log('❌ [RTC] Error handling offer: $e');
      }
    });
    _socket!.on('answer', (data) async {
      try {
        await _handleAnswer(data);
      } catch (e) {
        dev.log('❌ [RTC] Error handling answer: $e');
      }
    });
    _socket!.on('ice-candidate', (data) async {
      try {
        await _handleIceCandidate(data);
      } catch (e) {
        dev.log('❌ [RTC] Error handling ICE candidate: $e');
      }
    });

    // Global Events
    _socket!.on('mentor-left', (_) => onError?.call('The educational session has ended.'));
    _socket!.on('new-message', (data) => onChatMessage?.call(data['userName'] ?? 'Unknown', data['text']));
    _socket!.on('user-raised-hand', (data) => onHandRaised?.call(data['userName'] ?? 'Someone', data['isRaised'] ?? true));
    _socket!.on('room-list', (data) => onRoomListUpdate?.call(data as List<dynamic>));
    _socket!.on('new-announcement', (data) => onAnnouncementReceived?.call(Map<String, dynamic>.from(data as Map)));
    
    _socket!.on('media-permission-updated', (data) {
      if (data['targetId'] == _socket!.id || data['targetId'] == 'all') {
        onPermissionUpdate?.call(data['mic'] ?? false, data['video'] ?? false, data['screenShare'] ?? false);
      }
    });

    _socket!.on('screen-share-updated', (data) {
      if (onRemoteScreenShareUpdated != null) {
        onRemoteScreenShareUpdated!(data['socketId'], data['isSharing']);
      }
    });

    if (!_socket!.connected) _socket!.connect();
  }

  // --- WebRTC Core ---

  Future<RTCPeerConnection> _createPeerConnection(String remoteId, String localName) async {
    if (peerConnections.containsKey(remoteId)) {
      return peerConnections[remoteId]!;
    }

    RTCPeerConnection pc = await createPeerConnection(_rtcConfig);
    peerConnections[remoteId] = pc;

    // We no longer manually add transceivers here. 
    // If we have a local stream, we add tracks.
    // If we don't, setRemoteDescription will automatically create 
    // the necessary transceivers based on the remote offer.
    if (localStream != null) {
      for (var track in localStream!.getTracks()) {
        pc.addTrack(track, localStream!);
      }
    }

    pc.onIceCandidate = (candidate) {
      _socket!.emit('ice-candidate', {
        'target': remoteId,
        'candidate': candidate.toMap(),
        'fromName': localName,
      });
    };

    pc.onTrack = (event) {
      if (event.streams.isEmpty) return;
      final stream = event.streams[0];

      if (remoteStreams.containsKey(remoteId)) {
        if (remoteStreams[remoteId]!.id == stream.id) {
          // Same camera stream — a new track (e.g. video after audio) has
          // arrived. Re-fire the callback so the UI re-assigns srcObject on
          // the renderer and picks up the new track.
          dev.log('📹 [RTC] New track on existing stream for $remoteId — refreshing renderer');
          onRemoteStreamAdded?.call(remoteId, stream);
          return;
        }

        if (remoteScreenStreams[remoteId]?.id == stream.id) return;

        dev.log('🖥️ [RTC] Remote screen share stream detected for $remoteId');
        remoteScreenStreams[remoteId] = stream;
        onRemoteScreenStreamAdded?.call(remoteId, stream);
      } else {
        dev.log('📹 [RTC] Remote camera stream detected for $remoteId');
        remoteStreams[remoteId] = stream;
        onRemoteStreamAdded?.call(remoteId, stream);
      }
    };

    pc.onIceConnectionState = (state) {
      dev.log('❄️ [RTC] Connection state with $remoteId: $state');
      // Only remove if it's truly failed or closed. 
      // Disconnected can be temporary (network flip).
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
          state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
        _removePeer(remoteId);
      }
    };

    return pc;
  }

  // Add new callbacks
  Function(String participantId, MediaStream stream)? onRemoteScreenStreamAdded;
  Function(String participantId)? onRemoteScreenStreamRemoved;

  Future<void> _createFallbackStream(String remoteId, MediaStreamTrack track) async {
    if (remoteStreams.containsKey(remoteId)) {
      remoteStreams[remoteId]!.addTrack(track);
    } else {
      final stream = await createLocalMediaStream('remote_$remoteId');
      await stream.addTrack(track);
      remoteStreams[remoteId] = stream;
      onRemoteStreamAdded?.call(remoteId, stream);
    }
  }

  Future<void> _createOffer(String targetId, String localName) async {
    // Guard: don't create a new offer if we already have a stable connection.
    if (peerConnections.containsKey(targetId)) {
      final existing = peerConnections[targetId]!;
      if (existing.signalingState != RTCSignalingState.RTCSignalingStateClosed) {
        dev.log('⚠️ [RTC] Offer skipped: already have active PC for $targetId (state: ${existing.signalingState})');
        return;
      }
      peerConnections.remove(targetId);
    }

    try {
      final pc = await _createPeerConnection(targetId, localName);
      RTCSessionDescription offer = await pc.createOffer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 1,
      });
      await pc.setLocalDescription(offer);
      dev.log('📤 [RTC] Offer sent to $targetId');

      _socket!.emit('offer', {
        'target': targetId,
        'offer': offer.toMap(),
        'fromName': localName,
      });
    } catch (e) {
      dev.log('❌ [RTC] Failed to create offer to $targetId: $e');
      // Remove the broken PC so the watchdog can retry cleanly.
      peerConnections.remove(targetId);
    }
  }

  Future<void> _handleOffer(dynamic data, String localName) async {
    final String from = data['from'].toString();
    final String fromName = data['fromName'] ?? 'Remote';
    dev.log('📩 [RTC] Offer received from $fromName ($from)');

    final pc = await _createPeerConnection(from, localName);

    // --- W3C Glare (Collision) Handling ---
    // Both sides may have created offers simultaneously. Detect this and
    // resolve it so only one valid connection is established.
    if (pc.signalingState == RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
      final myId = _socket?.id ?? '';
      // The peer with the LARGER socket ID is 'polite' and rolls back.
      // The peer with the SMALLER socket ID is 'impolite' and wins.
      final isPolite = myId.compareTo(from) > 0;

      if (isPolite) {
        dev.log('🤝 [RTC] Glare detected — I am polite, rolling back my offer to accept theirs');
        try {
          await pc.setLocalDescription(RTCSessionDescription('', 'rollback'));
        } catch (e) {
          dev.log('❌ [RTC] Rollback failed: $e — recreating PC');
          peerConnections.remove(from);
          final newPc = await _createPeerConnection(from, localName);
          await newPc.setRemoteDescription(
              RTCSessionDescription(data['offer']['sdp'], data['offer']['type']));
          _remoteDescriptionsSet.add(from);
          final answer = await newPc.createAnswer();
          await newPc.setLocalDescription(answer);
          _socket!.emit('answer', {'target': from, 'answer': answer.toMap(), 'fromName': localName});
          return;
        }
      } else {
        dev.log('👊 [RTC] Glare detected — I am impolite, ignoring their offer (my offer takes precedence)');
        return; // Our offer will arrive at them; they will answer it.
      }
    }

    // Handle closed PC
    RTCPeerConnection activePc = pc;
    if (pc.signalingState == RTCSignalingState.RTCSignalingStateClosed) {
      peerConnections.remove(from);
      activePc = await _createPeerConnection(from, localName);
    }

    await activePc.setRemoteDescription(
        RTCSessionDescription(data['offer']['sdp'], data['offer']['type']));
    _remoteDescriptionsSet.add(from);

    // Process queued ICE candidates
    if (_iceQueues.containsKey(from)) {
      dev.log('❄️ [RTC] Flushing ${_iceQueues[from]!.length} queued ICE candidates for $from');
      for (var candidate in _iceQueues[from]!) {
        await activePc.addCandidate(candidate);
      }
      _iceQueues.remove(from);
    }

    final answer = await activePc.createAnswer();
    await activePc.setLocalDescription(answer);
    dev.log('📤 [RTC] Answer sent to $from');

    _socket!.emit('answer', {
      'target': from,
      'answer': answer.toMap(),
      'fromName': localName,
    });
  }

  Future<void> _handleAnswer(dynamic data) async {
    final String from = data['from'].toString();
    dev.log('📨 [RTC] Answer from $from');
    final pc = peerConnections[from];
    if (pc != null) {
      await pc.setRemoteDescription(RTCSessionDescription(data['answer']['sdp'], data['answer']['type']));
      _remoteDescriptionsSet.add(from);
      
      // Process queued ICE candidates
      if (_iceQueues.containsKey(from)) {
        dev.log('❄️ [RTC] Processing ${_iceQueues[from]!.length} queued ICE candidates for $from');
        for (var candidate in _iceQueues[from]!) {
          await pc.addCandidate(candidate);
        }
        _iceQueues.remove(from);
      }
    }
  }

  Future<void> _handleIceCandidate(dynamic data) async {
    final String from = data['from'].toString();
    final pc = peerConnections[from];
    final candidate = RTCIceCandidate(
        data['candidate']['candidate'], data['candidate']['sdpMid'], data['candidate']['sdpMLineIndex']);

    if (pc != null && _remoteDescriptionsSet.contains(from)) {
      await pc.addCandidate(candidate);
    } else {
      dev.log('❄️ [RTC] Queuing ICE candidate from $from (Remote description not yet set)');
      _iceQueues.putIfAbsent(from, () => []).add(candidate);
    }
  }

  void _removePeer(String id) {
    peerConnections[id]?.close();
    peerConnections.remove(id);
    participants.remove(id); // Ensure we remove from metadata map too
    _remoteDescriptionsSet.remove(id);
    remoteStreams.remove(id);
    remoteScreenStreams.remove(id);
    onRemoteStreamRemoved?.call(id);
    onRemoteScreenStreamRemoved?.call(id);
    onParticipantsChanged?.call();
  }

  // --- UI Actions ---

  void sendMessage(String text, String userName) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('send-message', {'roomId': _roomId, 'text': text, 'userName': userName});
    }
  }

  void raiseHand(String userName, bool isRaised) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('raise-hand', {'roomId': _roomId, 'userName': userName, 'isRaised': isRaised});
    }
  }

  void toggleAudio(bool enabled) {
    localStream?.getAudioTracks().forEach((track) {
      track.enabled = enabled;
    });
  }

  void toggleVideo(bool enabled) {
    localStream?.getVideoTracks().forEach((track) {
      track.enabled = enabled;
    });
  }

  Future<void> setSpeakerphoneOn(bool enabled) async {
    try {
      // ignore: deprecated_member_use
      await Helper.setSpeakerphoneOn(enabled);
      dev.log('🔊 [RTC] Speakerphone: $enabled');
    } catch (e) {
      dev.log('⚠️ [RTC] Speakerphone error: $e');
    }
  }

  Future<void> sendImage(XFile image, String userName) async {
    final bytes = await dart_io.File(image.path).readAsBytes();
    final base64Image = base64Encode(bytes);
    _socket!.emit('send-image', {
      'roomId': _roomId,
      'userName': userName,
      'text': '[Image]',
      'image': base64Image
    });
  }

  Future<void> switchCamera() async {
    if (localStream != null && localStream!.getVideoTracks().isNotEmpty) {
      final videoTrack = localStream!.getVideoTracks().first;
      // ignore: deprecated_member_use
      await Helper.switchCamera(videoTrack);
    }
  }

  void updateStudentPermission(String studentId, bool mic, bool video, bool screenShare) {
    if (_role == ClassroomRole.mentor && _socket != null) {
      _socket!.emit('update-media-permission', {
        'roomId': _roomId,
        'targetId': studentId,
        'mic': mic,
        'video': video,
        'screenShare': screenShare,
      });
    }
  }

  void updateAllStudentsPermission(bool mic, bool video, bool screenShare) {
    if (_role == ClassroomRole.mentor && _socket != null) {
      _socket!.emit('update-media-permission', {
        'roomId': _roomId,
        'targetId': 'all',
        'mic': mic,
        'video': video,
        'screenShare': screenShare,
      });
    }
  }

  Future<void> startScreenShare(String userName) async {
    try {
      localScreenStream = await navigator.mediaDevices.getDisplayMedia({
        'video': true,
        'audio': false,
      });

      // Add screen tracks to all existing peer connections
      for (var pc in peerConnections.values) {
        for (var track in localScreenStream!.getTracks()) {
          pc.addTrack(track, localScreenStream!);
        }
        
        // Renegotiate
        RTCSessionDescription offer = await pc.createOffer({
          'offerToReceiveAudio': 1,
          'offerToReceiveVideo': 1,
        });
        await pc.setLocalDescription(offer);
        _socket!.emit('offer', {
          'target': peerConnections.keys.firstWhere((k) => peerConnections[k] == pc),
          'offer': offer.toMap(),
          'fromName': userName,
        });
      }

      _socket!.emit('update-screen-share', {
        'roomId': _roomId,
        'isSharing': true
      });
      
      dev.log('🖥️ [RTC] Screen share started');
    } catch (e) {
      dev.log('❌ [RTC] Screen share error: $e');
      rethrow;
    }
  }

  void stopScreenShare() {
    if (localScreenStream != null) {
      for (var track in localScreenStream!.getTracks()) {
        track.stop();
      }
      localScreenStream!.dispose();
      localScreenStream = null;

      _socket!.emit('update-screen-share', {
        'roomId': _roomId,
        'isSharing': false
      });
      dev.log('🛑 [RTC] Screen share stopped');
    }
  }

  Future<void> startLocalStream() async {
    if (localStream != null) {
      dev.log('⚠️ [RTC] Local stream already exists, skipping initialization');
      return;
    }

    try {
      // Small safety delay to ensure no other camera operations are pending
      await Future.delayed(const Duration(milliseconds: 500));

      if (!kIsWeb) {
        var camStatus = await Permission.camera.status;
        var micStatus = await Permission.microphone.status;

        if (!camStatus.isGranted) {
          camStatus = await Permission.camera.request();
        }
        if (!micStatus.isGranted) {
          micStatus = await Permission.microphone.request();
        }

        if (!camStatus.isGranted || !micStatus.isGranted) {
          dev.log('❌ [RTC] Media permissions denied: cam=$camStatus mic=$micStatus');
          return;
        }
      }

      localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': 640,
          'height': 480,
        }
      });

      if (localStream == null) {
        throw Exception("Failed to acquire local media stream");
      }

      dev.log('✅ [RTC] Local stream acquired. Tracks: ${localStream!.getTracks().length}');

      // Add tracks to existing peer connections AND renegotiate.
      for (var entry in peerConnections.entries) {
        final id = entry.key;
        final pc = entry.value;

        // Guard: socket may have disconnected during the getUserMedia call.
        if (_socket == null || !_socket!.connected) {
          dev.log('⚠️ [RTC] Socket disconnected during renegotiation for $id — skipping');
          continue;
        }

        // Only add tracks if they aren't already there.
        final senders = await pc.getSenders();
        for (var track in localStream!.getTracks()) {
          bool alreadyAdded = senders.any((s) => s.track?.id == track.id);
          if (!alreadyAdded) {
            await pc.addTrack(track, localStream!);
          }
        }

        // Renegotiate.
        RTCSessionDescription offer = await pc.createOffer();
        await pc.setLocalDescription(offer);
        _socket!.emit('offer', {
          'target': id,
          'offer': offer.toMap(),
          'fromName': 'Participant',
        });
        dev.log('📤 [RTC] Renegotiation offer sent to $id');
      }

      dev.log('✅ [RTC] Local stream fully started and renegotiated');
    } catch (e) {
      dev.log('❌ [RTC] Error starting local stream: $e');
      // Do NOT rethrow here. A rethrow from an async function called inside
      // addPostFrameCallback becomes an unhandled Future rejection on Android
      // which crashes the Dart isolate ("GraduWay keeps stopping").
      // Instead, surface the error through the UI callback.
      localStream = null;
      onError?.call('Could not access camera/mic: ${e.toString().split('\n').first}');
    }
  }

  void stopLocalStream() {
    if (localStream != null) {
      dev.log('🔇 [RTC] Explicitly stopping ${localStream!.getTracks().length} tracks');
      for (var track in localStream!.getTracks()) {
        track.enabled = false;
        track.stop();
      }
      localStream!.dispose();
      localStream = null;
      dev.log('✅ [RTC] Local stream fully disposed');
    }
  }

  Future<void> leaveRoom() async {
    dev.log('🚪 [RTC] Leaving room $_roomId');
    if (_socket != null && _socket!.connected) {
      _socket!.emit('leave-room', {'roomId': _roomId});
      _socket!.disconnect();
    }
    dispose();
  }

  void dispose() {
    dev.log('🧹 [RTC] Disposing ClassroomService instance');
    stopLocalStream();
    
    peerConnections.forEach((id, pc) {
      dev.log('🔌 [RTC] Closing peer connection: $id');
      pc.close();
    });
    peerConnections.clear();
    remoteStreams.clear();
    participants.clear();
    
    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }
    dev.log('✨ [RTC] ClassroomService disposal complete');
  }
}
