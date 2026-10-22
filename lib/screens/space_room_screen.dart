import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/live_manager.dart';

class SpaceRoomScreen extends StatefulWidget {
  final LiveStreamItem streamItem;

  const SpaceRoomScreen({super.key, required this.streamItem});

  @override
  State<SpaceRoomScreen> createState() => _SpaceRoomScreenState();
}

class _SpaceRoomScreenState extends State<SpaceRoomScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String _statusMessage = 'Requesting camera & microphone permissions...';
  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      setState(() {
        _statusMessage = 'Requesting camera & microphone access...';
      });

      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }

      var micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        micStatus = await Permission.microphone.request();
      }

      if (cameraStatus.isGranted && micStatus.isGranted) {
        setState(() {
          _statusMessage = 'Initializing camera hardware...';
        });

        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          final frontCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          );
          _cameraController = CameraController(
            frontCamera,
            ResolutionPreset.medium,
            enableAudio: true,
          );
          await _cameraController!.initialize();
          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
              _statusMessage = '';
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _statusMessage = 'No camera found (Emulator). Using simulation view.';
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _statusMessage = 'Camera or Microphone permission denied.';
          });
        }
      }
    } catch (e) {
      debugPrint('Space camera init error: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Camera error: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveManager = Provider.of<LiveManager>(context);
    final currentStream = liveManager.activeStreams.firstWhere(
      (s) => s.id == widget.streamItem.id,
      orElse: () => widget.streamItem,
    );

    final focusedId = liveManager.focusedParticipantId ?? (currentStream.seats.isNotEmpty ? currentStream.seats.first.userId : null);
    final focusedSeat = currentStream.seats.firstWhere(
      (seat) => seat.userId == focusedId,
      orElse: () => currentStream.seats.first,
    );

    final isMeFocused = focusedSeat.userId.startsWith('me_') || focusedSeat.isHost;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentStream.title, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
            Text('Space • ${currentStream.seats.length}/${currentStream.maxSeats} Seats Active', style: const TextStyle(fontSize: 11, color: Colors.greenAccent)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            onPressed: () {
              liveManager.endLiveStream(currentStream.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. BIG SCREEN FOCUS VIEW (Real camera feed for local user / host, or status banner)
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurpleAccent, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (isMeFocused && _isCameraInitialized && _cameraController != null)
                    CameraPreview(_cameraController!)
                  else
                    Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          currentStream.backgroundPlaceholder,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.videocam_off, color: Colors.amberAccent, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  _statusMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                                  onPressed: _initCamera,
                                  icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                                  label: const Text('Retry Camera', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Overlay info
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.videocam, color: Colors.greenAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            focusedSeat.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Big Screen Spotlight', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. SEATS GRID (Up to 10 seats configuration as requested)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Seats (${currentStream.seats.length}/${currentStream.maxSeats})', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                if (currentStream.seats.length < currentStream.maxSeats)
                  TextButton.icon(
                    onPressed: () {
                      final mySeatIndex = currentStream.seats.length;
                      final newParticipant = SeatParticipant(
                        userId: 'me_${DateTime.now().millisecondsSinceEpoch}',
                        name: 'You (Co-Host Live)',
                        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
                        seatIndex: mySeatIndex,
                      );
                      liveManager.joinSeat(currentStream.id, newParticipant);
                      liveManager.setFocusedParticipant(newParticipant.userId);
                    },
                    icon: const Icon(Icons.person_add, size: 16, color: Colors.greenAccent),
                    label: const Text('Take a Seat & Go Live', style: TextStyle(color: Colors.greenAccent)),
                  ),
              ],
            ),
          ),

          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: currentStream.maxSeats,
              itemBuilder: (context, index) {
                final seatOccupant = currentStream.seats.firstWhere(
                  (s) => s.seatIndex == index,
                  orElse: () => SeatParticipant(userId: '', name: 'Empty', avatarUrl: '', seatIndex: index),
                );
                final isEmpty = seatOccupant.userId.isEmpty;
                final isSelected = seatOccupant.userId == focusedId;

                return GestureDetector(
                  onTap: () {
                    if (!isEmpty) {
                      liveManager.setFocusedParticipant(seatOccupant.userId);
                    }
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.deepPurpleAccent : (isEmpty ? Colors.white24 : Colors.greenAccent),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isEmpty
                            ? const CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white12,
                                child: Icon(Icons.person_outline, color: Colors.white54),
                              )
                            : CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(seatOccupant.avatarUrl),
                              ),
                        const SizedBox(height: 6),
                        Text(
                          isEmpty ? 'Seat ${index + 1}' : seatOccupant.name.split(' ').first,
                          style: TextStyle(color: isEmpty ? Colors.white38 : Colors.white, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. CHAT SECTION (Ephemeral)
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: liveManager.currentChatMessages.length,
                      itemBuilder: (context, index) {
                        final msg = liveManager.currentChatMessages[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${msg.senderName}: ${msg.message}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Chat in live space...',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepPurpleAccent, size: 20),
                        onPressed: () {
                          if (_msgController.text.trim().isNotEmpty) {
                            liveManager.addChatMessage('You', _msgController.text.trim());
                            _msgController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
